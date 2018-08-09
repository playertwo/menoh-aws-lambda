## Build fat version of the Menoh on the Amazon Linux AMI which uses in the AWS lambda

- Launch `r3.large` (this type use Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz processors, which is used in lambda) instance `amzn-ami-hvm-2017.03.1.20170812-x86_64-gp2 (ami-aa5ebdd2)`
- `sudo yum -y install git`
- `git clone https://github.com/playertwo/menoh-aws-lambda.git`
- `cd menoh-aws-lambda && ./build_menoh.sh http://registrationcenter-download.intel.com/___/l_mkl_2018.3.222.tgz`

Link to the static MKL archive you can get after registration https://software.intel.com/en-us/mkl


```
ldd ~/menoh/build/menoh/libmenoh.so
	linux-vdso.so.1 =>  (0x00007fffcb5dd000)
	libdl.so.2 => /lib64/libdl.so.2 (0x00007fc626516000)
	libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fc6262fa000)
	libm.so.6 => /lib64/libm.so.6 (0x00007fc625ff7000)
	libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007fc625de1000)
	libc.so.6 => /lib64/libc.so.6 (0x00007fc625a14000)
	/lib64/ld-linux-x86-64.so.2 (0x00005608915a0000)
```

```
ll ~/deps.zip
-rw-rw-r-- 1 ec2-user ec2-user 6983385 Jul 27 19:47 /home/ec2-user/deps.zip
```
