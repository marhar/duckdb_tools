#!/usr/bin/env python3
import hashlib
import sys
def compute_md5_hash_with_salt_and_spaces(s: str, salt: str = "#") -> str:
    """
    Computes the MD5 hash of the input string (including spaces) with a salt and returns a string of
    the same length as the input, composed of repeated MD5 hashes. Spaces from the input are preserved
    at the same positions. If the input is None, the function returns None.

    :param s: Input string
    :param salt: Salt character to be added before hashing
    :return: String of the same length as the input, composed of repeated MD5 hashes with spaces or None
    """
    if s is None:
        return None

    # Add the salt to the string
    salted_string = s + salt

    # Compute hash for the salted string
    md5_hash = hashlib.md5(salted_string.encode('utf-8')).hexdigest()
    repeated_hash = (md5_hash * (len(s) // len(md5_hash))) + md5_hash[:len(s) % len(md5_hash)]

    # Insert spaces back into their original positions
    output = ""
    hash_index = 0
    for char in s:
        if char == " ":
            output += " "
        else:
            output += repeated_hash[hash_index]
            hash_index += 1

    return output

c = compute_md5_hash_with_salt_and_spaces

"""
print(compute_md5_hash_with_salt_and_spaces(None))
print(compute_md5_hash_with_salt_and_spaces(''))
print(compute_md5_hash_with_salt_and_spaces('hello'))
print(compute_md5_hash_with_salt_and_spaces('hello world'))

print(compute_md5_hash_with_salt_and_spaces(None, 'salt'))
print(compute_md5_hash_with_salt_and_spaces('', 'salt'))
print(compute_md5_hash_with_salt_and_spaces('hello', 'salt'))
print(compute_md5_hash_with_salt_and_spaces('hello world', 'salt'))

print(compute_md5_hash_with_salt_and_spaces('x'*31))
print(compute_md5_hash_with_salt_and_spaces('x'*32))
print(compute_md5_hash_with_salt_and_spaces('x'*33))
"""

def test_compute_md5_hash_with_salt_and_spaces():
    # Define the inputs and expected outputs
    inputs = [
        None,
        '',
        'hello',
        'hello world',
        None,
        '',
        'hello',
        'hello world',
        'x'*31,
        'x'*32,
        'x'*33
    ]
    
    salts = [
        '#',
        '#',
        '#',
        '#',
        'salt',
        'salt',
        'salt',
        'salt',
        '#',
        '#',
        '#'
    ]

    expected_outputs = [
        None,
        '',
        '97ad6',
        '7656f a7524',
        None,
        '',
        'baddf',
        '010cf 14fc5',
        '8944c20c2eb019c02ea72ccf2238e8f',
        '23a7dbfcba49d8bc3a6c813c7bdb509c',
        '2b931c0181bf662bfc97c6467a0eec082'
    ]

    # Iterate over each input and compare the function's output to the expected output
    for i, s in enumerate(inputs):
        assert compute_md5_hash_with_salt_and_spaces(s, salts[i]) == expected_outputs[i]

    print("All tests passed!")

# Run the test function
test_compute_md5_hash_with_salt_and_spaces()
