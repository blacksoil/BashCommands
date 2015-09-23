#! /bin/bash

function test() {
	echo "123"
	return 1
}


test
echo "$?"
