# OsSignals

**Small project to help me wrap my head around how Erlang/OTP 20 handles OS signals.**

Based on [Financial-Times/k8s_traffic_plug](https://medium.com/@ellispritchard/graceful-shutdown-on-kubernetes-with-signals-erlang-otp-20-a22325e8ae98).


# How it works

Start the app with
```
$ mix run --no-halt
Compiling 1 file (.ex)
#PID<0.112.0>: "Running with OS PID: 21760."
#PID<0.113.0>: "Init."
#PID<0.113.0>: "Work started."
#PID<0.113.0>: "Work done, going to sleep."
#PID<0.113.0>: "Wake up call, starting to do some work."
#PID<0.113.0>: "Work started."
#PID<0.113.0>: "Work done, going to sleep."
#PID<0.113.0>: "Wake up call, starting to do some work."
#PID<0.113.0>: "Work started."
#PID<0.113.0>: "Work done, going to sleep."
```

Now in new terminal send SIGTERM to the OS process running it.

```
$ kill -s TERM 21760
```

The app will be notified from our custom signal handler and will refuse starting new work.

```
#PID<0.113.0>: "Wake up call, starting to do some work."
#PID<0.113.0>: "Work started."
#PID<0.47.0>: SIGTERM received. Stopping in 7000 ms.
#PID<0.113.0>: "Work done, going to sleep."
#PID<0.113.0>: "Asked to stop."
#PID<0.113.0>: "Wake up call, refusing to start work because stopping."
#PID<0.47.0>: Stopping due to earlier SIGTERM.
```
