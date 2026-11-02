const http = require('http');
const url = require('url');

const args = process.argv.slice(2);
let port = 8080;
let allowedOrigin = 'http://localhost:5555';

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--port' && args[i + 1]) port = parseInt(args[i + 1], 10);
  if (args[i] === '--origin' && args[i + 1]) allowedOrigin = args[i + 1];
}

let db = {
  publishers: [
    { id: 1, name: 'Азбука', city: 'Санкт-Петербург', website: 'https://azbooka.ru', deletedAt: null },
    { id: 2, name: 'АСТ', city: 'Москва', website: 'https://ast.ru', deletedAt: null },
    { id: 3, name: 'Эксмо', city: 'Москва', website: 'https://eksmo.ru', deletedAt: null },
    { id: 4, name: 'МИФ', city: 'Москва', website: 'https://mann-ivanov-ferber.ru', deletedAt: null },
  ],
  genres: [
    { id: 1, name: 'Роман / Проза', description: 'Художественная литература', deletedAt: null },
    { id: 2, name: 'Детектив', description: 'Расследования и тайны', deletedAt: null },
    { id: 3, name: 'Антиутопия и Фантастика', description: 'Будущее и фантастика', deletedAt: null },
    { id: 4, name: 'Философская притча', description: 'Поучительные сюжеты', deletedAt: null },
    { id: 5, name: 'Историческая драма', description: 'Исторические хроники', deletedAt: null },
  ],
  authors: [
    { id: 1, firstName: 'Лев', lastName: 'Толстой', country: 'Россия', birthYear: 1828, deletedAt: null },
    { id: 2, firstName: 'Фёдор', lastName: 'Достоевский', country: 'Россия', birthYear: 1821, deletedAt: null },
    { id: 3, firstName: 'Джордж', lastName: 'Оруэлл', country: 'Великобритания', birthYear: 1903, deletedAt: null },
    { id: 4, firstName: 'Франц', lastName: 'Кафка', country: 'Австро-Венгрия', birthYear: 1883, deletedAt: null },
    { id: 5, firstName: 'Габриэль', lastName: 'Гарсиа Маркес', country: 'Колумбия', birthYear: 1927, deletedAt: null },
    { id: 6, firstName: 'Харпер', lastName: 'Ли', country: 'США', birthYear: 1926, deletedAt: null },
    { id: 7, firstName: 'Михаил', lastName: 'Булгаков', country: 'Россия', birthYear: 1891, deletedAt: null },
    { id: 8, firstName: 'Эрих Мария', lastName: 'Ремарк', country: 'Германия', birthYear: 1898, deletedAt: null },
    { id: 9, firstName: 'Рэй', lastName: 'Брэдбери', country: 'США', birthYear: 1920, deletedAt: null },
    { id: 10, firstName: 'Антуан', lastName: 'де Сент-Экзюпери', country: 'Франция', birthYear: 1900, deletedAt: null },
  ],
  books: [
    { id: 1, title: 'Война и мир. Том 1', isbn: '978-5-389-06256-6', year: 1869, pages: 480, publisherId: 1, authorIds: [1], genreIds: [1, 5], copiesTotal: 5, copiesAvailable: 3, deletedAt: null },
    { id: 2, title: 'Война и мир. Том 2', isbn: '978-5-389-06257-3', year: 1869, pages: 448, publisherId: 1, authorIds: [1], genreIds: [1, 5], copiesTotal: 4, copiesAvailable: 2, deletedAt: null },
    { id: 3, title: 'Анна Каренина', isbn: '978-5-17-090658-1', year: 1877, pages: 864, publisherId: 2, authorIds: [1], genreIds: [1], copiesTotal: 3, copiesAvailable: 1, deletedAt: null },
    { id: 4, title: 'Преступление и наказание', isbn: '978-5-389-04924-6', year: 1866, pages: 608, publisherId: 1, authorIds: [2], genreIds: [1, 2], copiesTotal: 7, copiesAvailable: 4, deletedAt: null },
    { id: 5, title: 'Братья Карамазовы', isbn: '978-5-17-084534-7', year: 1880, pages: 840, publisherId: 2, authorIds: [2], genreIds: [1, 4], copiesTotal: 6, copiesAvailable: 5, deletedAt: null },
    { id: 6, title: 'Идиот', isbn: '978-5-389-07521-4', year: 1869, pages: 640, publisherId: 1, authorIds: [2], genreIds: [1], copiesTotal: 5, copiesAvailable: 0, deletedAt: null },
    { id: 7, title: '1984', isbn: '978-5-17-080115-2', year: 1949, pages: 320, publisherId: 2, authorIds: [3], genreIds: [3], copiesTotal: 10, copiesAvailable: 8, deletedAt: null },
    { id: 8, title: 'Скотный двор', isbn: '978-5-17-090334-4', year: 1945, pages: 128, publisherId: 2, authorIds: [3], genreIds: [3, 4], copiesTotal: 8, copiesAvailable: 6, deletedAt: null },
    { id: 9, title: 'Процесс', isbn: '978-5-389-05510-0', year: 1925, pages: 288, publisherId: 1, authorIds: [4], genreIds: [1, 4], copiesTotal: 4, copiesAvailable: 2, deletedAt: null },
    { id: 10, title: 'Замок', isbn: '978-5-17-094121-6', year: 1926, pages: 352, publisherId: 2, authorIds: [4], genreIds: [1, 4], copiesTotal: 3, copiesAvailable: 3, deletedAt: null },
    { id: 11, title: 'Сто лет одиночества', isbn: '978-5-17-085077-8', year: 1967, pages: 480, publisherId: 2, authorIds: [5], genreIds: [1, 4], copiesTotal: 6, copiesAvailable: 2, deletedAt: null },
  ],
  readers: [
    {
      id: 1,
      fullName: 'Иван Иванов',
      email: 'ivanov@example.com',
      phone: '+79991112233',
      card: { cardNumber: 'CARD-1001', issuedAt: '2026-01-15T00:00:00.000Z', expiresAt: '2027-01-15T00:00:00.000Z', isActive: true },
      deletedAt: null
    },
    {
      id: 2,
      fullName: 'Анна Смирнова',
      email: 'smirnova@example.com',
      phone: '+79992223344',
      card: { cardNumber: 'CARD-1002', issuedAt: '2026-02-10T00:00:00.000Z', expiresAt: '2027-02-10T00:00:00.000Z', isActive: true },
      deletedAt: null
    }
  ]
};

let nextId = { books: 12, authors: 11, genres: 6, publishers: 5, readers: 3 };

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(data, null, 2));
}

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const q = parsedUrl.query;

  // Логирование запросов в консоль терминала
  console.log(`[Mock Server] ${req.method} ${req.url}`);

  // Предварительный запрос CORS (OPTIONS)
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': allowedOrigin,
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    return res.end();
  }

  const delay = parseInt(q._delay || 0, 10);
  const fail = parseInt(q._fail || 0, 10);

  setTimeout(() => {
    if (fail >= 400) {
      return sendJson(res, fail, { message: `Имитация серверного сбоя (${fail})` });
    }

    // Health-check и корень
    if (path === '/api/_health' || path === '/_health') {
      return sendJson(res, 200, { status: 'ok', serverTime: new Date().toISOString() });
    }

    if (path === '/' || path === '/api' || path === '/api/') {
      return sendJson(res, 200, {
        message: 'Учебный REST API сервер работает',
        availableEndpoints: [
          '/api/books',
          '/api/authors',
          '/api/genres',
          '/api/publishers',
          '/api/readers',
          '/api/_health'
        ]
      });
    }

    // Универсальный разбор пути: убираем /api и лишние слэши
    const cleanPath = path.replace(/^\/api(\/|$)/, '').replace(/^\/+|\/+$/g, '');
    const segments = cleanPath ? cleanPath.split('/') : [];
    const entity = segments[0];
    const id = segments[1] ? parseInt(segments[1], 10) : null;
    const action = segments[2];

    if (!entity || !db[entity]) {
      return sendJson(res, 404, {
        message: `Эндпоинт "${path}" не найден`,
        hint: 'Доступные сущности: books, authors, genres, publishers, readers'
      });
    }

    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      let data = {};
      if (body) {
        try { data = JSON.parse(body); } catch (_) {}
      }

      // 1. Восстановление: POST /api/:entity/:id/restore
      if (req.method === 'POST' && id && action === 'restore') {
        const item = db[entity].find(x => x.id === id);
        if (!item) return sendJson(res, 404, { message: 'Запись не найдена' });
        item.deletedAt = null;
        return sendJson(res, 200, item);
      }

      // 2. Множественное удаление: POST /api/:entity/bulk-delete
      if (req.method === 'POST' && segments[1] === 'bulk-delete') {
        const ids = data.ids || [];
        let count = 0;
        for (const targetId of ids) {
          const item = db[entity].find(x => x.id === targetId && !x.deletedAt);
          if (item) {
            item.deletedAt = new Date().toISOString();
            count++;
          }
        }
        return sendJson(res, 200, { deleted: count });
      }

      // 3. Список сущностей: GET /api/:entity
      if (req.method === 'GET' && !id) {
        let list = db[entity].filter(x => q.includeDeleted === 'true' || !x.deletedAt);

        if (q.search && q.search.trim()) {
          const needle = q.search.trim().toLowerCase();
          list = list.filter(x =>
            (x.title && x.title.toLowerCase().includes(needle)) ||
            (x.name && x.name.toLowerCase().includes(needle)) ||
            (x.lastName && x.lastName.toLowerCase().includes(needle)) ||
            (x.fullName && x.fullName.toLowerCase().includes(needle)) ||
            (x.isbn && x.isbn.toLowerCase().includes(needle))
          );
        }

        if (q.genreId && entity === 'books') {
          list = list.filter(b => b.genreIds && b.genreIds.includes(parseInt(q.genreId, 10)));
        }
        if (q.publisherId && entity === 'books') {
          list = list.filter(b => b.publisherId === parseInt(q.publisherId, 10));
        }
        if (q.yearFrom && entity === 'books') {
          list = list.filter(b => b.year >= parseInt(q.yearFrom, 10));
        }
        if (q.yearTo && entity === 'books') {
          list = list.filter(b => b.year <= parseInt(q.yearTo, 10));
        }

        if (q.sort) {
          const [field, dir] = q.sort.split(',');
          const asc = dir !== 'desc';
          list.sort((a, b) => {
            const vA = a[field];
            const vB = b[field];
            if (typeof vA === 'string') return asc ? vA.localeCompare(vB) : vB.localeCompare(vA);
            return asc ? (vA - vB) : (vB - vA);
          });
        }

        const total = list.length;
        const page = parseInt(q.page || 1, 10);
        const size = parseInt(q.size || 10, 10);
        const from = (page - 1) * size;
        const items = list.slice(from, from + size);

        return sendJson(res, 200, { items, page, size, total });
      }

      // 4. Карточка: GET /api/:entity/:id
      if (req.method === 'GET' && id) {
        const item = db[entity].find(x => x.id === id);
        if (!item) return sendJson(res, 404, { message: 'Запись не найдена' });
        return sendJson(res, 200, item);
      }

      // 5. Создание: POST /api/:entity
      if (req.method === 'POST' && !id) {
        if (entity === 'books') {
          const dup = db.books.find(b => b.isbn.replace(/[-\s]/g, '') === (data.isbn || '').replace(/[-\s]/g, ''));
          if (dup) {
            return sendJson(res, 422, {
              message: 'Ошибка валидации',
              errors: { isbn: 'Книга с таким ISBN уже существует' }
            });
          }
        }
        if (entity === 'readers') {
          const dup = db.readers.find(r => r.email.toLowerCase() === (data.email || '').toLowerCase());
          if (dup) {
            return sendJson(res, 422, {
              message: 'Ошибка валидации',
              errors: { email: 'Читатель с таким адресом почты уже зарегистрирован' }
            });
          }
        }

        const newItem = { ...data, id: nextId[entity]++, deletedAt: null };
        db[entity].push(newItem);
        return sendJson(res, 201, newItem);
      }

      // 6. Обновление: PUT /api/:entity/:id
      if (req.method === 'PUT' && id) {
        const index = db[entity].findIndex(x => x.id === id);
        if (index === -1) return sendJson(res, 404, { message: 'Запись не найдена' });

        if (entity === 'books') {
          const dup = db.books.find(b => b.id !== id && b.isbn.replace(/[-\s]/g, '') === (data.isbn || '').replace(/[-\s]/g, ''));
          if (dup) {
            return sendJson(res, 422, {
              message: 'Ошибка валидации',
              errors: { isbn: 'Книга с таким ISBN уже существует' }
            });
          }
        }

        db[entity][index] = { ...data, id, deletedAt: db[entity][index].deletedAt };
        return sendJson(res, 200, db[entity][index]);
      }

      // 7. Удаление: DELETE /api/:entity/:id
      if (req.method === 'DELETE' && id) {
        if (entity === 'publishers') {
          const linkedBooks = db.books.filter(b => b.publisherId === id && !b.deletedAt);
          if (linkedBooks.length > 0) {
            return sendJson(res, 409, {
              message: `Невозможно удалить издательство: к нему привязано ${linkedBooks.length} книг(и). Сначала измените или удалите связанные книги.`
            });
          }
        }

        const index = db[entity].findIndex(x => x.id === id);
        if (index === -1) return sendJson(res, 404, { message: 'Запись не найдена' });

        if (q.hard === 'true') {
          db[entity].splice(index, 1);
        } else {
          db[entity][index].deletedAt = new Date().toISOString();
        }
        return sendJson(res, 200, { message: 'Успешно удалено' });
      }

      sendJson(res, 405, { message: 'Метод не поддерживается' });
    });
  }, delay);
});

server.listen(port, () => {
  console.log(`[Mock Server] Запущен: http://localhost:${port}/api`);
  console.log(`[Mock Server] CORS разрешён для: ${allowedOrigin}`);
});
