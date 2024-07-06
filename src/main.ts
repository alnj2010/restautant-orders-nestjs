import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as mysql from 'mysql2/promise';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);

  try {
    const connection = await mysql.createConnection({
      host: 'kitchen_db_container',
      user: 'root',
      password: 'root',
      port: 3306,
      database: 'kitchen_db',
    });
    connection.query(`CREATE TABLE IF NOT EXISTS Persons (
      PersonID int,
      LastName varchar(255),
      FirstName varchar(255),
      Address varchar(255),
      City varchar(255)
);`);
    console.log('----------------Si Conecto!!');
  } catch (error) {
    throw error;
  }
}
bootstrap();
