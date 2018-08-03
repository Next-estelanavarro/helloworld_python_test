# -*- coding: utf-8 -*-

class Greeter:
    def __init__(self):
        self.message = 'Hello world!'
        pass
        #print self.message

    def get_message(self):
    	return self.message

    def set_message(self, message):
    	self.message = message
    	