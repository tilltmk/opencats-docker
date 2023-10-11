# 🐳 OpenCATS Docker Setup
This repository contains one of the rare Docker setups for OpenCATS that works.

Installation:
1. Clone this repository to your local system: ```git clone https://github.com/tilltmk/opencats opencats && cd opencats```
2. Open the file docker-compose.yml and update the environment variables under opencats-db and phpmyadmin with your own values.
3. Start the Docker containers with the command: ```docker-compose up -d ```
4. Open a web browser and go to http://localhost:4000 to access the OpenCATS application.
5. Setup database connection with your custom credentials from the docker-compose file and with the database hostname opencats-db
6. (Optional) If you want to use phpMyAdmin, go to http://localhost:8090.

## Configuration:

After starting the Docker containers, you can find and edit the OpenCATS configuration file at /var/www/html/config.php in the opencats container.

## Support:

If you need help or want to report bugs, please open an issue in this repository.

Thank you for using this Docker setup for OpenCATS!
