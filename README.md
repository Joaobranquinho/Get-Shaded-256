# Get Shaded :two::five::six:

<img src="https://github.com/tiagoramalho/Get-Shaded-256/blob/master/imgs/sha.png">

**University Project - Reconfigurable Computing**
```
In 17 of October 2018 bitcoin registered an all time record of
60 000 000 trillions of hashes per second.
```
*Source: <a href="blockchain.com">blockchain.com</a>*

## Problem
In the Reconfigurable Computing course, my co-worker <a href="https://github.com/Joaobranquinho">João Branquinho</a> and I were challenged to develop a project where we could explore the advantages of using co-processors integrated with Microblaze processor.
We had already heard about Bitcoin and it's proof of work algorithm based on sha-256 computations. And we had also heard about the use of devices like FPGAs, GPUs, ASICs etc. that are used to take advantage of the parallelization properties of sha-256. After some search, we figured that this would be our project.

## Objective
The main objective of this project is to develop a fast way of computing sha-256 hashes. Single cored software solutions depend on at least 64 clock cycles to perform a full sha-256 hash computation. While this may be a good approach when dealing with common computers, one can argue that a better solution would involve having one co-processor (or several) dedicated to sha-256 computations. When using such devices the calculation times can be reduced by 75% (48 clock cycles total).

## Implementation

Implementation is a critical part of our project has it can significantly improve performance results. In our personal implementation (aimed to be deployed on a low-spec FPGA) we strive to present a PoC using both interruptions and a Microblaze processor.
The Microblaze processor contains a 32-bit Processor Core and a set of instructions that are more than enough from a developing standpoint. Moreover, it also has a UART and a Timer (we don't make use of the last one). Interruptions are useful for signaling. Our implementation implicates that a value indicating the number of zeros (crypto-challenge) is passed on. The coprocessor checks the number of zeros. If the crypto-puzzle is solved it throws an exception.
Our implementation also allows for a variable number of co-processors to be deployed. This becomes useful when deploying on more robust FPGA's.

## Requirements
The full list of requirements is comprised of one item:
 - FPGA Kit sotftware (Xilinx software in our case)

