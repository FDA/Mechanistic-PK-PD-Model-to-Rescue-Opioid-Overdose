# -*- coding: utf-8 -*-


import tensorflow as tf
import numpy as np
import tensorflow.contrib.layers as tcl
import csv
import os
from datetime import datetime
import glob
from datetime import datetime

now = datetime.now()

current_time = now.strftime("%H:%M:%S")

#elapsed=current_time2-current_time

print("Start Time =", current_time)


os.environ["CUDA_VISIBLE_DEVICES"]="0"   #GPU 0 used for training and 1 for prediction


now = datetime.utcnow().strftime("%Y%m%d%H%M%S")
root_logdir = "tf_logs_j1"
logdir = "{}/run-{}/".format(root_logdir, now)


class Model(object):
    
    def __init__(self, model_path, train_mode=True, input_dim=25, T=180, prev=1,
                 lstm_size=256,
                 batch_size=100, e_learning_rate=1e-4,
                 ):
        self.model_path = model_path
        self.train_mode = train_mode
        self.input_dim = input_dim
        self.T = T
        self.prev = prev

        self.enc_size = lstm_size        
        
        self.batch_size = batch_size
        self.e_learning_rate = e_learning_rate

        self._srng = np.random.RandomState(np.random.randint(1,2147462579))
        
        self.lstm_enc = tf.contrib.rnn.LSTMCell(self.enc_size, state_is_tuple=True)
        
        # initial state
        self.enc_state = self.lstm_enc.zero_state(self.batch_size, tf.float32)
        self.ys = [0] * self.T
        self.y_prev = 0.0
        self.e_loss = 0.0
        
        # build computation graph of model
        self.DO_SHARE=None
        self.x = tf.placeholder(tf.float32, shape=[None, self.input_dim]) #self.x is for parameters.
       # self.ymax = tf.placeholder(tf.float32, shape=[None, 1])          #peak is always 1
        self.y = tf.placeholder(tf.float32, shape=[None, self.T])         #self.y is the time course of ventilation
        
        xe = self.input_embedding(self.x)
        #self.h = self.height_model(xe)                                    #the 2nd fully connected network is to predict peak                          
        #self.p_loss = tf.reduce_mean(tf.square(self.h - self.ymax))
        #self.e_loss += self.p_loss
        
        for t in range(self.T): 
            
            self.y_prev = self.get_yprev(t)
            h_enc, self.enc_state = self.encode(self.enc_state, tf.concat([xe, self.y_prev], 1))
            ylt = self.linear(h_enc)
            self.ys[t] = tf.sigmoid(ylt)
            y_true = tf.reshape(self.y[:,t], [-1, 1])
            self.e_loss +=tf.reduce_mean(tf.square(y_true - self.ys[t])) #MSE
             
            self.DO_SHARE = True

        self.e_vars = tf.trainable_variables()

        self.e_optimizer = tf.train.AdamOptimizer(self.e_learning_rate, beta1=0.5, beta2=0.999)
        e_grads = self.e_optimizer.compute_gradients(self.e_loss, self.e_vars)
        clip_e_grads = [(tf.clip_by_norm(grad, 5), var) for grad, var in e_grads if grad is not None]
        self.e_optimizer = self.e_optimizer.apply_gradients(clip_e_grads)


        self.eloss_summary = tf.summary.scalar('eloss', self.e_loss)
       # self.ploss_summary=tf.summary.scalar('ploss',self.p_loss)
        self.file_writer = tf.summary.FileWriter(logdir, tf.get_default_graph())



        """
        if self.train_mode == False:
            self.sess = tf.Session()
            saver = tf.train.Saver()
            saver.restore(self.sess, self.model_path + "/mymodel-10") #
            # code to load test data
            xtest =
            ytest =
            ptest =
            ys, h = self.sess.run([self.ys, self.h], feed_dict={self.x: xtest, self.y: ytest, self.ymax: ptest})
            # code save result
            self.sess.close()
        """
    
    def train(self, train_set, valid_set, maxEpoch=10):
        
         with tf.Session() as sess:
            
            saver = tf.train.Saver()
            sess.run(tf.global_variables_initializer())
            
            i = 0
            loss_v=np.zeros((maxEpoch,4))  #only 4 because no peak values
            for epoch in range(maxEpoch): # range for python3
                Lds = []                       #no Lps
                Ldvs = []                
                for xtrain, ytrain in self.data_loader(train_set, self.batch_size, shuffle=True):
                    #ytrain = ytrain[:,::-1]
                    
                    _, Le, ys = sess.run([self.e_optimizer, self.e_loss, self.ys], 
                                     feed_dict={self.x: xtrain, self.y: ytrain})
                    Ld=Le
                    Lds.append(Ld)
                    #Lps.append(Lp)
                    i += 1
                    
                    if i % 1000 == 0:
                        summary_str_e = self.eloss_summary.eval(feed_dict={self.x: xtrain, self.y: ytrain})
                        
                        self.file_writer.add_summary(summary_str_e, i)
                        
                for xvalid, yvalid in self.data_loader(valid_set, self.batch_size):
                   # yvalid = yvalid[:,::-1]
                    
                    Lev, ysv = sess.run([self.e_loss, self.ys], feed_dict={self.x: xvalid, self.y: yvalid})
                    Ldv=Lev
                    Ldvs.append(Ldv)
                   # Lpvs.append(Lpv)
                Ld_train_mean = np.array(Lds).mean()
               # Lp_train_mean = np.array(Lps).mean()
                Ld_valid_mean = np.array(Ldvs).mean()
                #Lp_valid_mean = np.array(Lpvs).mean()
                Ld_train_std = np.array(Lds).std()
                #Lp_train_std = np.array(Lps).std()
                Ld_valid_std = np.array(Ldvs).std()
                #Lp_valid_std = np.array(Lpvs).std()
#                pdb.set_trace()
                loss_v[epoch,:]=[Ld_train_mean, Ld_valid_mean, Ld_train_std,  Ld_valid_std]                

            
                self.save_model(saver, sess, step=epoch)
                np.savetxt('save_j1/loss2.txt', loss_v )
            self.file_writer.close()
    
    def data_loader(self, train_set, batchsize, shuffle=False): 
        features, labels = train_set
        if shuffle:
            indices = np.arange(len(features))
            self._srng.shuffle(indices)
        for start_idx in range(0, len(features) - batchsize + 1, batchsize):
            if shuffle:
                excerpt = indices[start_idx:start_idx + batchsize]
            else:
                excerpt = slice(start_idx, start_idx + batchsize)
            yield features[excerpt], labels[excerpt]
        
    def data_loader2(self, predict_set, batchsize, shuffle=False): 
        features = predict_set
        if shuffle:
            indices = np.arange(len(features))
            self._srng.shuffle(indices)
        for start_idx in range(0, len(features) - batchsize + 1, batchsize):
            if shuffle:
                excerpt = indices[start_idx:start_idx + batchsize]
            else:
                excerpt = slice(start_idx, start_idx + batchsize)
            yield features[excerpt]
    
    def save_model(self, saver, sess, step):
        """
        save model with path error checking
        """
        if self.model_path is None:
            my_path = "save" # default path in tensorflow saveV2 format
            # try to make directory if "save" path does not exist
            if not os.path.exists("save"):
                try:
                    os.makedirs("save")
                except OSError as e:
                    if e.errno != errno.EEXIST:
                        raise
        else: 
            my_path = self.model_path + "/mymodel"
                
        saver.save(sess, my_path, global_step=step)
    
    
    def encode(self, state, input):
        """
        run LSTM
        state = previous encoder state
        input = cat(read,h_dec_prev)
        returns: (output, new_state)
        """
        with tf.variable_scope("e_lstm",reuse=self.DO_SHARE):
            return self.lstm_enc(input,state)
            
    #fully_connected creates a variable called weights,
    #representing a fully connected weight matrix, which is multiplied by the inputs to produce a Tensor of hidden units
    def linear(self, x):
        with tf.variable_scope("e_linear", reuse=self.DO_SHARE):
            yl = tcl.fully_connected(inputs=x, num_outputs=1, activation_fn=None)
        return yl # output logits w.r.t sigmoid
    
    def input_embedding(self, x):
        with tf.variable_scope("e_eblinear1", reuse=None):
            h1 = tcl.fully_connected(inputs=x, num_outputs=128, activation_fn=tf.nn.relu)
        with tf.variable_scope("e_eblinear2", reuse=None):
            h2 = tcl.fully_connected(inputs=x, num_outputs=64, activation_fn=tf.nn.relu)
        return h2
    
    

    def get_yprev(self, t):
        with tf.variable_scope("e_yprev", reuse=self.DO_SHARE):
            yp_init = tf.get_variable('yp_init', [self.batch_size, self.prev], initializer=tf.constant_initializer(0.5))
        return yp_init if t == 0 else tf.concat([self.y_prev[:,1:], self.ys[t-1]], 1)
            

if __name__ == "__main__":
    
    # TODO: preprocessing dataset
    # Load data from csv file


    train_mode = False 
   
    mymodel = Model("savedoriginal_model3", train_mode=train_mode, input_dim=15, T=961,batch_size=256)
    saver = tf.train.Saver()
  
   
    path = '/training/nonshuffled/opioids/carfentanil_10_120_0.25_bs2'

    files=glob.glob(path)
    with tf.Session() as sess:
        saver.restore(sess,"training/savedoriginal_model3/mymodel-277")
    
    
        for file in files:
            with open(file) as csvfile1:
                mpg = list(csv.reader(csvfile1, quoting=csv.QUOTE_NONNUMERIC))
                results=np.array(mpg).astype("float") 
            #data structure: 0:9 PK/PD parameters; 10 alpha; 11 opioid_dose, 12 naloxone_doseN,
            #13 delay 14 threshold 
            #15:975 time course
            #note below 0:15 extracts 0-14 and 15:976 extracts 15-975
                predict_set = results[:,0:15]
                youtput = np.array([],dtype=np.float32).reshape(0,961)
                newfilename = file + '_predictedolong'
                for xtest in mymodel.data_loader2(predict_set, batchsize = mymodel.batch_size, shuffle=False):
                 
                    yst = sess.run(mymodel.ys, feed_dict={mymodel.x: xtest})
                    arrayt = np.transpose(np.squeeze(yst))
                    youtput = np.concatenate((youtput, arrayt),axis=0)
                                 #  with open(newfilename,'a') as csvfile2:

                with open(newfilename,'a') as csvfile2:
                    np.savetxt(csvfile2, youtput, fmt='%.2e',delimiter=',')
            
              


    
            from datetime import datetime

now = datetime.now()

current_time2 = now.strftime("%H:%M:%S")

#elapsed=current_time2-current_time

print("End Time =", current_time2)
