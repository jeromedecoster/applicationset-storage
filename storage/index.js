const { S3Client, ListObjectsV2Command, PutObjectCommand } = require("@aws-sdk/client-s3")
const { fromEnv, fromIni } = require('@aws-sdk/credential-providers')
const debug = require('debug')('storage')
// https://www.npmjs.com/package/is-docker/v/2.2.1
// use 2.2.1 fixed version to prevent the error : Error [ERR_REQUIRE_ESM]: require() 
const isDocker = require('is-docker')
const express = require('express')
const multer = require('multer')


for (var name of ['NODE_ENV', 'AWS_S3_BUCKET', 'AWS_REGION', 'STORAGE_PORT']) {
    if (process.env[name] == null || process.env[name].length == 0) { 
        throw new Error(`${name} environment variable is required`)
    }
    console.log(`process.env.${name}: ${process.env[name]}`)
}

const NODE_ENV = process.env.NODE_ENV
const AWS_S3_BUCKET = process.env.AWS_S3_BUCKET
const AWS_REGION = process.env.AWS_REGION
const STORAGE_PORT = process.env.STORAGE_PORT

// console.log(`env.AWS_ACCESS_KEY_ID: ${process.env.AWS_ACCESS_KEY_ID}`)
// console.log(`env.AWS_SECRET_ACCESS_KEY: ${process.env.AWS_SECRET_ACCESS_KEY}`)
// console.log("isDocker()", isDocker())


const credentials = isDocker() ? fromEnv() : fromIni()
const s3 = new S3Client({ region: AWS_REGION, credentials })

const app = express()

var upload = multer({ storage: multer.memoryStorage() })

app.get('/', (req, res) => {
    res.send('storage API')
})

app.get('/healthcheck', (req, res) => {
    res.json({ uptime: process.uptime() })
})

// curl localhost:5000/photos
app.get('/photos', async (req, res) => {
    try {
        const listObjectsV2Command = new ListObjectsV2Command({
            Bucket: AWS_S3_BUCKET,
            // Prefix: 'ko'
        })
        
        const result =  await s3.send(listObjectsV2Command)
        debug('result', result)

        if (result.Contents == undefined) {
            return res.json([])
        }
        
        // sort by newest first
        const sorted = result.Contents.sort((a, b) => b.LastModified - a.LastModified)
        // sorted.reverse()
        debug('sorted', sorted)
        let arr = []
        for (var content of sorted) {
            arr.push(`https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${content.Key}`)
        } 
        
        return res.json(arr)
    } catch(err) {
        return res.status(400).send(`Error: ${err.message}`)
    }
})

// curl --request POST --form "file=@test/rhino.webp" --form "name=rhino.webp" --silent http://localhost:5000/upload
app.post('/upload', upload.any(), async (req, res) => {
    debug('req.files:', req.files)
    if (req.files == undefined || req.files.length == 0) {
        return res.status(400).send('Field file is required')
    }
    const file = req.files.find(e => e.fieldname == 'file')
    debug('file:', file)

    const putObjectCommand = new PutObjectCommand({
        Bucket: AWS_S3_BUCKET,
        ContentType: 'image',
        Key: file.originalname,
        Body: file.buffer,
        ACL : 'public-read'
    });
    
    try {
        const result =  await s3.send(putObjectCommand)
        debug('result:', result)
        return res.send(result.Location)
    } catch(err) {
        return res.status(400).send(`Error: ${err.message}`)
    }
})

app.listen(STORAGE_PORT, () => { 
    console.log(`Listening on port ${STORAGE_PORT}`) 
})