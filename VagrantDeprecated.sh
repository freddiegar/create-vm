#!/bin/sh

echo "Access with root!"
sudo su
echo

echo "Repository PHP 5.5"
add-apt-repository -y ppa:ondrej/php
echo

echo "System update"
aptitude update
echo 

#echo "Install MySQL Client"
#aptitude -y install mysql-client-core-5.5
#echo 

echo "Install Apache Server and enabled SSL"
aptitude -y install apache2.2-common
a2enmod ssl
a2enmod rewrite
echo 

echo "Install PHP 5.5"
aptitude -y install php5
aptitude -y install php5-gd
aptitude -y install php5-curl
aptitude -y install php5-mysql
aptitude -y install php5-mcrypt
php5enmod mcrypt
aptitude -y install php5-intl
echo

echo "Create site in Apache: /etc/apache2/sites-available/##NAME_VM##.conf"
echo '<VirtualHost *:80>
    ServerName ##NAME_VM##.freddie.dev
    ServerAdmin fredy.mendivelso@placetopay.com
    DocumentRoot /var/www

    <Directory /var/www>
            DirectoryIndex index.php index.html
            Options Indexes FollowSymLinks
            AllowOverride All
            <IfVersion >= 2.4>
                Require all granted
            </IfVersion>
            <IfVersion < 2.4>
                Order allow,deny
                Allow from all
            </IfVersion>
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet' > /etc/apache2/sites-available/##NAME_VM##.conf
echo

echo "Create site SSL in Apache: /etc/apache2/sites-available/##NAME_VM##-ssl.conf"
echo '<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerName ##NAME_VM##.freddie.dev
                ServerAdmin fredy.mendivelso@placetopay.com
                DocumentRoot /var/www

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on
                SSLCertificateFile      /var/www/ssl/server-cert.pem
                SSLCertificateKeyFile   /var/www/ssl/server-cert.key
                SSLCertificateChainFile /var/www/ssl/server-cert-intermediate.pem

                #SSLCACertificatePath /etc/ssl/certs/
                SSLCACertificateFile /usr/cnf/certificates/server-ca-chain.pem

                #SSLCARevocationPath /etc/apache2/ssl.crl/
                #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl


                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

                BrowserMatch "MSIE [2-6]" \
                                nokeepalive ssl-unclean-shutdown \
                                downgrade-1.0 force-response-1.0
                # MSIE 7 and newer should be able to use keepalive
                BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

                <Directory /var/www>
                    DirectoryIndex index.php index.html
                    AllowOverride All
                </Directory>

                SSLSessionCacheTimeout 1

                <Location ~ "/?(.*)/secure">
                    LogLevel info ssl:debug
                    SSLOptions +StdEnvVars
                    SSLVerifyClient optional
                    SSLVerifyDepth 2
                </Location>

        </VirtualHost>
</IfModule>' > /etc/apache2/sites-available/##NAME_VM##-ssl.conf
echo

echo "Changes permission"
chmod 770 /etc/apache2/sites-available/##NAME_VM##.conf
chmod 770 /etc/apache2/sites-available/##NAME_VM##-ssl.conf
echo

echo "Changes owners"
chown vagrant:www-data /etc/apache2/sites-available/##NAME_VM##.conf
chown vagrant:www-data /etc/apache2/sites-available/##NAME_VM##-ssl.conf
echo

echo "Disable default sites"
a2dissite 000-default.conf
a2dissite default-ssl.conf
echo

echo "Enable to site"
a2ensite ##NAME_VM##.conf
a2ensite ##NAME_VM##-ssl.conf
service apache2 reload
echo

echo "Finish"