# Configure TPM

## with SSH

There are a few methods on how to configure SSH using TPM.
Many sources recommend to use `tpm2-tools`:

- https://tris.fyi/blog/tpm-keys.html
- https://incenp.org/notes/2020/tpm-based-ssh-key.html
- https://jade.fyi/blog/tpm-ssh/

But we will be using an ssh-agent to automate this process!
The main explanation is found on the authors [blog post](https://linderud.dev/blog/store-ssh-keys-inside-the-tpm-ssh-tpm-agent/).
By using [ssh-tpm-agent.nix](./ssh-tpm-agent.nix) we automate the setup of the utilities,
like installing the `ssh-tpm-agent` package and setting the systemd processes,
both for the system and for the user!
The system process also generated two pairs of keys: RSA and ECDSA (Elliptic Curve Digital Signature Algorithm).
The public key has the same structure, but the private one differs in two ways:

1. The comment says it is generated via TSS2, and not using OpenSSH
2. The files have the `.tpm` ending,
   so normal agents should not pick the up (they can't handle them).

Using the `ssh-tpm-keygen` command we can generate user keys using the TPM module.
It defualts to ECDSA and will be placed in `.ssh`,
with the only difference being that the private key has an ending

To use such a key, the correct agent socket needs to be specified with `SSH_AUTH_SOCK`.
If the public key `.ssh/id_ecdsa.pub` is provided to GitHub, one can test it with

```sh
SSH_AUTH_SOCK=/run/user/1000/ssh-tpm-agent.sock ssh git@github.com
```

## with Gnome Keyring

https://221b.uk/gnome-login-using-u2f-security-tokens
