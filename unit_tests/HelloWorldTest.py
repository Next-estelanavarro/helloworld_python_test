# -*- coding: utf-8 -*-

import unittest
from HelloWorld import Greeter

class MyTestCase(unittest.TestCase):
    def test_default_greeting_set(self):
        greeter = Greeter()
        self.assertEqual(greeter.message, 'Hello world!')

    def test_set_message_foo(self):
    	greeter = Greeter()
    	greeter.set_message("foo")
    	self.assertEqual(greeter.message, "foo")

	def test_get_message_foo(self):
    	greeter = Greeter()
    	greeter.message = "foo"
    	self.assertEqual(greeter.get_message(), "foo")

if __name__ == '__main__':
    unittest.main()