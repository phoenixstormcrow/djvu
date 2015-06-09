/* fileapi.js
   uses the File API to allow users to import .wav files
   into a local, sandboxed file system.
*/

/* TODO: the FileSystem object should really be a singleton */

// get the api -- webkit
window.requestFileSystem = window.requestFileSystem ||
                           window.webkitRequestFileSystem;

var GB = 1*1024*1024*1024; // 1GB

/* TODO: do something with this */
function errorHandler(e) { console.log(e); }

function Wav(fileEntry) {
    this.name = fileEntry.name;
    if (fileEntry.toURL) {
        this.url = fileEntry.toURL(); // maxim can import these from the sandbox
    } else {
        this.url = fileEntry.url; // for files on the server
    }
}

function FileSystem() {
    this.size = GB;
    this.name = '';
    this.fs = undefined; // a reference to the result of requestFileSystem -- a DOMFileSystem object
    this.wavs = [new Wav({name:'dub-breakbeat.wav', url:'dub-breakbeat.wav'}),
                 new Wav({name:'choir-nec-invenit-requiem.wav', url:'choir-nec-invenit-requiem.wav'})
                ], // a couple of wavs to start with -- these will be on my server
    this.input = document.getElementById('fileInput');
    this.input.onchange = (function (e) { this.importSelected(e.target.files); }).bind(this);

}

FileSystem.prototype.init = function (fs) {
    this.fs = fs;
    this.name = fs.name;
    // we need to read the entries already stored and put them in wavs
    this.readDir(); //this'll do it
};

/* from http://www.html5rocks.com/en/tutorials/file/filesystem/#toc-dir-reading */
function toArray(list) {
    return Array.prototype.slice.call(list || [], 0);
}
FileSystem.prototype.readDir = function () {
    var dirReader = this.fs.root.createReader();
    var entries = [];
    var obj = this;

    var readEntries = function () {
        dirReader.readEntries(function(results) {
            if (!results.length) {
                //done reading, do something with entries
                obj.updateWavs(entries);
            } else {
                entries = entries.concat(toArray(results));
                readEntries();
            }
        }, errorHandler);
    };

    //start reading
    readEntries();
};

FileSystem.prototype.updateWavs = function (entries) {
    for (var i = 0, l = entries.length; i < l; ++i) {
        var wav = new Wav(entries[i]);
        if (this.wavs.indexOf(wav) == -1) {
            this.wavs.push(wav);
        }
    }
}

FileSystem.prototype.get = function () {
    obj=this;
    navigator.webkitPersistentStorage.requestQuota(
        obj.size,
        function(granted) {
            obj.size = granted;
            window.requestFileSystem(PERSISTENT,
                         granted, function (fs) {obj.init(fs);},
                         errorHandler);
        }, errorHandler);
};

FileSystem.prototype.importSelected = function (files) { //copies the files selected by user to sandbox
    for (var i=0, file; file = files[i]; ++i) {
    (function(f) {
        obj = this;
        this.fs.root.getFile(file.name, {create: true, exclusive: false},
            function (fileEntry) {
                fileEntry.createWriter(function (fileWriter) {
                    fileWriter.write(f);
                    //update wav array
                    var wav = new Wav(fileEntry);
                    if (obj.wavs.indexOf(wav) == -1) {
                        obj.wavs.push(wav);
                    }
                    if (i == files.length) {
                        obj.importing = false; //we're done
                    }
               }, errorHandler);
            }, errorHandler);
    }).call(this, file);
    }
};

/* we'll go ahead and do some set up due to some Processing quirks */
function createInput() {
  if (document.getElementById('fileInput') == null) {
    var inp = document.createElement('input');
    inp.type = 'file';
    inp.multiple = 'true';
    inp.accept = 'audio/wav';
    inp.id = 'fileInput';
    inp.hidden = 'true';
    document.body.appendChild(inp);
  }
}

/* fsys is global because it's easier, and also so we can get it from the console.
   Doing it here sets it up properly, whereas calling these functions from setup()
   results in a filesystem with no name.
*/
function getFS() {
  fsys = new FileSystem();
/* FIXME */
  // fsys.get();
}

window.addEventListener('load', createInput, false);
window.addEventListener('load', getFS, false);
