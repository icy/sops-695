# sops-695

Discussed in https://github.com/mozilla/sops/issues/695

```
diff bad/fooobar.yaml good/fooobar.yaml 
6d5
<     ##
```

`good` is not so good, because my very first comment lines are gone.

# filelist

* `.sops.yaml`: The sops configuration
* `bad`: The original yaml file, and its output generated by sops. The output is a broken yaml file
* `good`: The orignal yaml file, and its output generated by sops. The output is fine, can be decrypted by sops.
  However, some very first comment lines are gone.
* `sops_secure_encryption.sh`: The Bash4 script (on Linux) I used to execute encryption + cross-check.
  This works for most yaml files on my system, except the `bad/fooobar.yaml`

# original source

https://gist.github.com/icy/d567dcf6e767d22e3683eb075a442967
