# Lexicon

This repository contains the Next.js SPA, FastAPI application, origin server
and reverse proxy configurations, infrastructure-as-code, and automation scripts
for a full-stack software system that provides browser-based access to an
ISO-24613-compliant machine-readable dictionary containing lexicographic data
that is in the public domain and that is foundational to Late Modern English.

## Technology Stack

### Operating System:
* Ubuntu 22.04

### Frontend:
#### Languages:
* ECMAScript (JavaScript)
* HTML5
* CSS
* JSX (syntax extension to JavaScript)
#### Framework:
* Next.js

### Backend:
#### Reverse Proxy:
* nginx
#### Application Server:
* Uvicorn
#### Database:
* MongoDB Community Edition 7.0.14
   * [Lexicographic data](/backend/data_sample.json)
#### File Systems:
* ext4
   * source code
* XFS
   * audio files
   * MongoDB WiredTiger files
#### Web Framework:
* FastAPI
#### Application Language:
* Python 3.12

## Linux Tools Used
Bash, Git, LVM2 suite, OpenSSH suite, Vim, mkfs.xfs, mount

## Contributing

This is not an open source project. I've made the repository public mainly to
evidence my skills in full-stack web development and my aptness for a job in
that field. I'm not accepting contributors.

