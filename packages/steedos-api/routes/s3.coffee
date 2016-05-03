Busboy = Npm.require('busboy');
Fiber = Npm.require('fibers');

JsonRoutes.parseFiles = (req, res, next) ->
    files = []; # Store files in an array and then pass them to request.
    image = {}; # crate an image object

    if (req.method == "POST") 
      busboy = new Busboy({ headers: req.headers });
      busboy.on "file",  (fieldname, file, filename, encoding, mimetype) ->
        image.mimeType = mimetype;
        image.encoding = encoding;
        image.filename = filename;

        # buffer the read chunks
        buffers = [];

        file.on 'data', (data) ->
          buffers.push(data);

        file.on 'end', () ->
          # concat the chunks
          image.data = Buffer.concat(buffers);
          # push the image object to the file array
          files.push(image);


      busboy.on "field", (fieldname, value) ->
        req.body[fieldname] = value;

      busboy.on "finish",  () ->
        # Pass the file array together with the request
        req.files = files;

        Fiber ()->
          next();
        .run();
      
      # Pass request to busboy
      req.pipe(busboy);
    
    else
      next();
    

#JsonRoutes.Middleware.use(JsonRoutes.parseFiles);

JsonRoutes.add "post", "/s3/",  (req, res, next) ->

  JsonRoutes.parseFiles req, res, ()->
    collection = cfs.instances

    if req.files and req.files[0]

      newFile = new FS.File();
      newFile.attachData req.files[0].data, {type: req.files[0].mimeType}, (err) ->
        newFile.name(req.files[0].filename);

        collection.insert newFile,  (err, fileObj) ->
          resp = {
            version_id: fileObj._id
            size: fileObj.size 
          };
          res.setHeader("x-amz-version-id",fileObj._id);
          res.end(JSON.stringify(resp));
          return
    else
      res.statusCode = 500;
      res.end();

   
JsonRoutes.add "delete", "/s3/",  (req, res, next) ->

  collection = cfs.instances

  id = req.query.version_id;
  if id
    file = collection.findOne({ _id: id })
    if file
      file.remove()
      resp = {
        status: "OK"
      }
      res.end(JSON.stringify(resp));
      return

  res.statusCode = 404;
  res.end();

   
JsonRoutes.add "get", "/s3/",  (req, res, next) ->

  id = req.query.version_id;

  res.statusCode = 302;
  res.setHeader "Location", Meteor.absoluteUrl("api/files/instances/") + id + "?download=1"
  res.end();


Meteor.methods 

  s3_upgrade: (min, max) ->
    console.log("/s3/upgrade")

    fs = Npm.require('fs')
    mime = Npm.require('mime')

    root_path = "/mnt/fakes3/10"
    console.log(root_path)
    collection = cfs.instances

    # 遍历instance 拼出附件路径 到本地找对应文件 分两种情况 1./filename_versionId 2./filename；
    deal_with_version = (root_path, space, ins_id, version, attach_filename) ->
      _rev = version._rev
      created_by = version.created_by
      approve = version.approve
      filename = version.filename || attach_filename;
      mime_type = mime.lookup(filename)
      new_path = root_path + "/spaces/" + space + "/workflow/" + ins_id + "/" + filename + "_" + _rev
      old_path = root_path + "/spaces/" + space + "/workflow/" + ins_id + "/" + filename

      readFile = (full_path) ->
        data = fs.readFileSync full_path
         
        if data
          newFile = new FS.File();
          newFile._id = _rev;
          newFile.metadata = {owner:created_by, space:space, instance:ins_id, approve: approve};
          newFile.attachData data, {type: mime_type}
          newFile.name(filename)
          fileObj = collection.insert newFile
          console.log(fileObj._id)
          
      try 
        n = fs.statSync new_path
        if n && n.isFile()
          readFile new_path
      catch error
        try 
          old = fs.statSync old_path
          if old && old.isFile()
            readFile old_path
        catch error
          console.error("file not found: " + old_path)
          

    count = db.instances.find({"attachments.current": {$ne: null}}).count();
    console.log("all instances: " + count)
    
    b = new Date()

    i = min
    db.instances.find({"attachments.current": {$ne: null}}, {skip: min, limit: max-min}).forEach (ins) ->
      i = i + 1
      console.log(i)
      attachs = ins.attachments
      space = ins.space
      ins_id = ins._id
      attachs.forEach (att) ->
        deal_with_version root_path, space, ins_id, att.current, att.filename
        if att.historys
          att.historys.forEach (his) ->
            deal_with_version root_path, space, ins_id, his, att.filename

    console.log(new Date() - b)

    return "ok"



