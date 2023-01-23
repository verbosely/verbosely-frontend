# Lexicon

*A single-page web application for visualizing lexicographic data in the
browser.*

## Overview

This repository contains the core code base, server configuration files,
and documentation for a locally hosted, single-page web application that
retrieves and displays lexicographic data from a 1915 printing of
*Webster's New International Dictionary of the English Language* - the
third great revision of Noah Webster's original *American Dictionary of
the English Language*.

This web application presents semi-structured, hierarchical textual data
in a unique format that provides convenience of consultation and brings
a full and scholarly treatment of the whole field of the English
language to the browser. The data whereon the code depends is not
contained in this repository; it is stored in a MongoDB database on a
local machine.

This repository mainly exists to evidence the administrator's skills in
full stack web development and his aptness for a full-time job therein.
He is the sole contributor to Lexicon, and no pull requests are
currently being granted.

## Technology Stack

### Host:
* Amazon Web Services
   * Elastic Compute Cloud (EC2)
      * Amazon Machine Image: Ubuntu 20.04.5 LTS
      * Region: US East (Ohio)
      * Storage: SSD-based EBS volumes

### Development OS:
* Linux
   * Ubuntu 22.04.1 LTS

### Frontend:
#### Languages:
* ECMAScript 2015 (JavaScript)
* HTML5
* CSS
#### Toolchain:
* Create React App
   * React
   * Babel
   * webpack
   * ESLint
   * Jest
   * PostCSS

### Backend:
#### Web Servers:
* nginx
* Gunicorn
#### Database:
* MongoDB Community Edition 6.0.3
   * [Lexicographic data](/backend/data_sample.json)
#### File Systems:
* ext4
   * source code
* XFS
   * audio files
   * MongoDB WiredTiger files
#### Web Framework:
* Flask
   * Werkzeug
   * Jinja
   * MarkupSafe
   * ItsDangerous
   * Click
#### Application Language:
* Python 3.11
