importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.js');

let initSqlJs = null;
let db = null;

self.onmessage = async function(e) {
  try {
    const { id, method, args } = e.data;
    
    if (method === 'init') {
      const SQL = await initSqlJs();
      db = new SQL.Database();
      self.postMessage({ id, result: 'initialized' });
      return;
    }

    if (!db) {
      const SQL = await initSqlJs();
      db = new SQL.Database();
    }

    let result;
    if (method === 'exec') {
      result = db.run(...args);
    } else if (method === 'export') {
      result = db.export();
    } else {
      result = null;
    }

    self.postMessage({ id, result });
  } catch (error) {
    self.postMessage({ id: e.data.id, error: error.message });
  }
};
