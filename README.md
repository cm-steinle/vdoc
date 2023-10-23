# README - tomcat + mysql

# Terminal

    docker exec -it tomcat-mysql-vdoc-1 /bin/bash

'''
  db:
    image: mysql:5
    ports:
      - "3306:3306"
    volumes: 
      - vol-db:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: ieBeiquooJaefua0kahph8sheim3Cohg
      MYSQL_DATABASE: VDoc
      MYSQL_USER: v-doc
      MYSQL_PASSWORD: ohcaw2oocoh1Aeg8ta0zohh9cu9teivu
    restart: always
'''

