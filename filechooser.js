/* filechooser.js
   works with fileapi.js
   displays a dialog for selecting one of the files stored in the sandbox
*/

function Chooser(fs) {
    this.fsys = fs; //the FileSystem object defined in fileapi.js

    /* DOM manipulation */
    this.div = document.createElement('div');
    this.div.className = 'chooser hidden';
    this.listElem = document.createElement('ul');
    
    /* FIXME */
    this.notImplemented = document.createElement('p');
    this.notImplemented.textContent = "This feature is not available in this demo.";
    
    this.importButton = document.createElement('button');
    this.importButton.id = 'importButton';
    
    /* FIXME */
    this.importButton.disabled = true;
    
    this.importButton.innerHTML = 'Import files';
    this.cancelButton = document.createElement('button');
    this.cancelButton.id = 'cancelButton';
    this.cancelButton.innerHTML = 'Cancel';
   
    /* FIXME */
    this.div.appendChild(this.notImplemented);
    
//    this.div.appendChild(this.listElem);

    this.div.appendChild(document.createElement('hr'));//for layout ease
    this.div.appendChild(this.importButton);
    this.div.appendChild(this.cancelButton);
    document.body.appendChild(this.div);

    /* callbacks */    
    this.importButton.onclick = (function () {
        this.fsys.importing = true;
        this.fsys.input.click();
        setTimeout(this.update.bind(this), 500);
    }).bind(this);
    this.cancelButton.onclick = (function () {
        this.cancel();
    }).bind(this);

    /* flag variables */    
    this.selected = undefined;
    this.visible = false;
}

Chooser.prototype.update = function () {
    if (this.fsys.importing) {
        setTimeout(this.update.bind(this), 500);
    } else {
        this.populate();
    }
};

Chooser.prototype.populate = function () {

//    var ls = this.fsys.wavs,
//        le = this.listElem;
//    le.innerHTML = '';
//    for (var i = 0, l = ls.length; i < l; ++i) {
//        var li = document.createElement('li');
//        li.id = i;
//        li.onclick = this.lsclick.bind(this);
//        li.innerHTML = ls[i].name;
//        le.appendChild(li);
//    }
};

Chooser.prototype.lsclick = function lsclick(e) {
    
    var id = parseInt(e.target.id);
    this.selected = fsys.wavs[id].url;
    this.hide();
};

Chooser.prototype.show = function () {
    this.visible = true;
    this.selected = undefined;
    this.populate();
    /* position the dialog in the middle of the screen */
    var rect = this.div.getBoundingClientRect();
    var left = document.body.getBoundingClientRect().width/2 - rect.width/2;
    this.div.style.left = left.toString() + "px";
    this.div.className = 'chooser visible';
};

Chooser.prototype.hide = function () {
    this.visible = false;
    this.div.className = 'chooser hidden';
};

Chooser.prototype.cancel = function () {
    this.hide();
};

