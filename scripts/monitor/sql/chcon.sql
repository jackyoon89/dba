alter session set container=cdb$root;
show pdbs

accept cont prompt 'Input the container name: ';

alter session set container=&cont;
