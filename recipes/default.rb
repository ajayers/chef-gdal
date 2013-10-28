gdal_version = node['gdal']['version']

tarball = "gdal-#{gdal_version}.tar"
tarball_gz = "gdal-#{gdal_version}.tar.gz"
gdal_url = node['gdal']['download_url'] || "http://download.osgeo.org/gdal/#{tarball_gz}"

remote_file "/tmp/#{tarball_gz}" do
  source gdal_url
  mode "0644"
  action :create_if_missing
end

fgdb_tarball_gz = 'FileGDB_API_1_3-64.tar.gz'
remote_file "/tmp/#{fgdb_tarball_gz}" do
  source "http://downloads2.esri.com/Software/#{fgdb_tarball_gz}"
  mode '0644'
  action :create_if_missing
end

bash "install_filegdb_api" do
  code <<-EOC
    cd /opt && \
    tar xzvf /tmp/#{fgdb_tarball_gz} && \
    echo '/opt/FileGDB_API/lib' > /etc/ld.so.conf.d/filegdb.conf && \
    ldconfig
  EOC
end

bash "install_gdal_#{gdal_version}" do
  untar_dir = "/usr/local/src"
  user "root"
  code <<-EOH
    cd #{untar_dir} && \
    tar xzvf /tmp/#{tarball_gz} && \
    cd gdal-#{gdal_version} && \
    ./configure --with-pg=yes --with-fgdb=/opt/FileGDB_API && make && make install && \
    ldconfig
  EOH
  command ""
  creates "/usr/local/bin/gdal-config"
  action :run
end
