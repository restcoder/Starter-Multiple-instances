'use strict';


var express = require('express');
var app = express();
var pg = require('pg');

app.get("/products", function (req, res, next) {
  pg.connect(process.env.POSTGRES_URL, function (err, client, done) {
    if (err) {
      return next(err);
    }
    client.query("SELECT * from product ORDER BY id ASC", function (err, result) {
      done();
      if (err) {
        return next(err);
      }
      res.json(result.rows);
    });
  });
});

const sql = `
CREATE TABLE "product"
(
    id SERIAL NOT NULL,
    name character varying(20) NOT NULL,
    quantity int NOT NULL,
    CONSTRAINT product_pkey PRIMARY KEY (id)
);
`;

app.listen(process.env.PORT, function () {
  if (process.env.INSTANCE_NR === '0') {
    pg.connect(process.env.POSTGRES_URL, function (err, client, done) {
      if (err) {
        throw err;
      }
      client.query(sql, function (err) {
        if (err) {
          throw err;
        }
        done();
        console.log('READY');
      });
    });
  } else {
    console.log('READY');
  }
});