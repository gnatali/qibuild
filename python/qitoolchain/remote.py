## Copyright (C) 2011 Aldebaran Robotics

""" Set of tools to perform remote operations,
downloading package or reading configs from URLs

"""

import os
import sys
import urllib2

import qibuild



def callback(total, done):
    """ Called during download """
    if not sys.stdout.isatty():
        return
    percent = done * 100 / total
    sys.stdout.write("Done: %i%%\r" % percent)
    sys.stdout.flush()


def download(url, output_dir, callback=callback, clobber=True):
    """ Download a file from an url, and save it
    in output_dir.

    The name of the file will be the basename of the url,
    and a nice progressbar will be printed during the download

    If clobber is False, the file won't be overwritten if it
    already exists

    """
    dest_name = url.split("/")[-1]
    dest_name = os.path.join(output_dir, dest_name)

    error = None

    if os.path.exists(dest_name) and not clobber:
        return dest_name

    try:
        dest_file = open(dest_name, "w")
    except Exception, e:
        mess  = "Could not save %s to %s\n" % (url, dest_name)
        mess += "Error was %s" % e
        raise Exception(mess)

    try:
        url_obj = urllib2.urlopen(url)
        content_length = url_obj.headers.dict['content-length']
        size = int(content_length)
        buff_size = 100 * 1024
        xferd = 0
        while xferd < size:
            data = url_obj.read(buff_size)
            if not data:
                break
            xferd += len(data)
            if callback:
                callback(size, xferd)
            dest_file.write(data)
    except Exception, e:
        error  = "Could not dowload file from %s\n to %s\n" % (url, dest_name)
        error += "Error was: %s" % e
    finally:
        dest_file.close()
        url_obj.close()
    if error:
        raise Exception(error)

    return dest_name


def get_remote_config(url):
    """ Read a config from an url.

    The format of the file should be the same as the one used by
    qibuild.configstore

    Return a qibuild.configstore.ConfigStore object

    """
    with qibuild.sh.TempDir() as tmp:
        try:
            url_obj = urllib2.urlopen(url)
            contents = url_obj.read()
            conf_file = os.path.join(tmp, "conf")
            with open(conf_file, "w") as fp:
                fp.write(contents)
            url_obj.close()
            config = qibuild.configstore.ConfigStore()
            config.read(conf_file)
            return config
        except Exception, e:
            mess  = "Could not read configuration from %s\n" % url
            mess += "Error was: %s" % e
            raise Exception(mess)

