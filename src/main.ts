import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as pg from 'pg';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);

  try {
    const { Client } = pg;
    const client = new Client({
      user: 'postgres',
      password: 'root',
      host: 'kitchen_db_container',
      port: 5432,
      database: 'postgres',
    });
    await client.connect();
    /* 
     client.query(`CREATE TABLE IF NOT EXISTS Persons (
      PersonID int,
      LastName varchar(255),
      FirstName varchar(255),
      Address varchar(255),
      City varchar(255)
);`);*/
    await client.end();
    console.log('----------------Si Conecto!!');
  } catch (error) {
    console.log('----------------NO Conecto!!', error);
    //throw error;
  }
}
bootstrap();
