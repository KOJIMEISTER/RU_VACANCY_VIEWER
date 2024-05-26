PGDMP                       |            itddb    16.2    16.1 -    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    34109    itddb    DATABASE     y   CREATE DATABASE itddb WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE itddb;
                postgres    false            �            1255    77971    set_original_and_duplicated() 	   PROCEDURE     �  CREATE PROCEDURE public.set_original_and_duplicated()
    LANGUAGE plpgsql
    AS $$
declare
	original record;
	doubble record;
begin
	update vacancy set vac_hash = md5(vac_description) where vac_hash is NULL;
	for original in (select distinct on (vac_hash) vac_id, vac_hash from vacancy)
	loop
		update vacancy set vac_original = 'true' where vac_id = original.vac_id;
	end loop;
	update vacancy set vac_duplicate = 'true' where vac_original = 'false';
	refresh materialized view all_techs;
end;
$$;
 5   DROP PROCEDURE public.set_original_and_duplicated();
       public          postgres    false            �            1259    34110    vacancy    TABLE     �  CREATE TABLE public.vacancy (
    vac_id bigint NOT NULL,
    vac_name character varying(512) NOT NULL,
    vac_company character varying(512) NOT NULL,
    vac_pay_from bigint,
    vac_pay_to bigint,
    vac_pay_cur character varying(64),
    vac_pay_gross boolean,
    vac_area character varying(256),
    vac_archived boolean DEFAULT false NOT NULL,
    vac_exp character varying(64) NOT NULL,
    vac_schedule character varying(64) NOT NULL,
    vac_employment character varying(64) NOT NULL,
    vac_description character varying(16384) NOT NULL,
    vac_hash character varying(64),
    vac_published date NOT NULL,
    vac_role_id character varying(64),
    vac_original boolean DEFAULT false NOT NULL,
    vac_duplicate boolean DEFAULT false NOT NULL
);
    DROP TABLE public.vacancy;
       public         heap    postgres    false            �           0    0    TABLE vacancy    ACL     �   GRANT SELECT ON TABLE public.vacancy TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.vacancy TO utile_agent;
          public          postgres    false    215            �            1259    40470 
   all_cities    VIEW     �   CREATE VIEW public.all_cities AS
 SELECT vac_area,
    count(*) AS count
   FROM public.vacancy
  WHERE ((vac_archived = false) AND (vac_original = true))
  GROUP BY vac_area
  ORDER BY (count(*)) DESC;
    DROP VIEW public.all_cities;
       public          postgres    false    215    215    215            �           0    0    TABLE all_cities    ACL     �   GRANT SELECT ON TABLE public.all_cities TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.all_cities TO utile_agent;
          public          postgres    false    217            �            1259    77917    vacancy_dataset    TABLE     i   CREATE TABLE public.vacancy_dataset (
    vac_id bigint NOT NULL,
    type_name character varying(64)
);
 #   DROP TABLE public.vacancy_dataset;
       public         heap    postgres    false            �           0    0    TABLE vacancy_dataset    ACL     >   GRANT SELECT ON TABLE public.vacancy_dataset TO client_agent;
          public          postgres    false    224            �            1259    44013    vacancy_roles    TABLE     �   CREATE TABLE public.vacancy_roles (
    role_id character varying(64) NOT NULL,
    category_id character varying(64) NOT NULL,
    role_name character varying(256)
);
 !   DROP TABLE public.vacancy_roles;
       public         heap    postgres    false                        0    0    TABLE vacancy_roles    ACL     �   GRANT SELECT ON TABLE public.vacancy_roles TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.vacancy_roles TO utile_agent;
          public          postgres    false    221            �            1259    77914    vacancy_types    TABLE     �   CREATE TABLE public.vacancy_types (
    type_name character varying(64) NOT NULL,
    role_id character varying(64) NOT NULL
);
 !   DROP TABLE public.vacancy_types;
       public         heap    postgres    false                       0    0    TABLE vacancy_types    ACL     <   GRANT SELECT ON TABLE public.vacancy_types TO client_agent;
          public          postgres    false    223            �            1259    77929    all_dataset_roles    VIEW     S  CREATE VIEW public.all_dataset_roles AS
 SELECT vacancy_types.role_id,
    vacancy_roles.role_name,
    count(*) AS count
   FROM ((public.vacancy_dataset
     JOIN public.vacancy_types USING (type_name))
     JOIN public.vacancy_roles USING (role_id))
  GROUP BY vacancy_types.role_id, vacancy_roles.role_name
  ORDER BY (count(*)) DESC;
 $   DROP VIEW public.all_dataset_roles;
       public          postgres    false    223    224    221    223    221                       0    0    TABLE all_dataset_roles    ACL     @   GRANT SELECT ON TABLE public.all_dataset_roles TO client_agent;
          public          postgres    false    226            �            1259    77920 	   all_roles    VIEW     �  CREATE VIEW public.all_roles AS
 SELECT vacancy_roles.role_name,
    vacancy.vac_role_id,
    count(*) AS count
   FROM (public.vacancy
     JOIN public.vacancy_roles ON (((vacancy.vac_role_id)::text = (vacancy_roles.role_id)::text)))
  WHERE ((vacancy.vac_archived = false) AND (vacancy.vac_original = true))
  GROUP BY vacancy_roles.role_name, vacancy.vac_role_id
  ORDER BY (count(*)) DESC;
    DROP VIEW public.all_roles;
       public          postgres    false    215    221    221    215    215                       0    0    TABLE all_roles    ACL     �   GRANT SELECT ON TABLE public.all_roles TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.all_roles TO utile_agent;
          public          postgres    false    225            �            1259    34153    vacancy_techs    TABLE     q   CREATE TABLE public.vacancy_techs (
    vac_id bigint NOT NULL,
    tech_name character varying(128) NOT NULL
);
 !   DROP TABLE public.vacancy_techs;
       public         heap    postgres    false                       0    0    TABLE vacancy_techs    ACL     �   GRANT SELECT ON TABLE public.vacancy_techs TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.vacancy_techs TO utile_agent;
          public          postgres    false    216            �            1259    78124 	   all_techs    MATERIALIZED VIEW     D  CREATE MATERIALIZED VIEW public.all_techs AS
 SELECT vacancy_techs.tech_name,
    count(*) AS count
   FROM (public.vacancy_techs
     JOIN public.vacancy USING (vac_id))
  WHERE ((vacancy.vac_archived = false) AND (vacancy.vac_original = true))
  GROUP BY vacancy_techs.tech_name
  ORDER BY (count(*)) DESC
  WITH NO DATA;
 )   DROP MATERIALIZED VIEW public.all_techs;
       public         heap    postgres    false    215    216    216    215    215                       0    0    TABLE all_techs    ACL     8   GRANT SELECT ON TABLE public.all_techs TO client_agent;
          public          postgres    false    227            �            1259    40910    all_vacancies    VIEW     K   CREATE VIEW public.all_vacancies AS
 SELECT vac_id
   FROM public.vacancy;
     DROP VIEW public.all_vacancies;
       public          postgres    false    215                       0    0    TABLE all_vacancies    ACL     �   GRANT SELECT ON TABLE public.all_vacancies TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.all_vacancies TO utile_agent;
          public          postgres    false    218            �            1259    40914    cleared_vacancies    VIEW     �  CREATE VIEW public.cleared_vacancies AS
 SELECT vac_id,
    vac_name,
    vac_company,
    vac_pay_from,
    vac_pay_to,
    vac_pay_cur,
    vac_pay_gross,
    vac_area,
    vac_archived,
    vac_exp,
    vac_schedule,
    vac_employment,
    vac_description,
    vac_hash,
    vac_published,
    vac_role_id
   FROM public.vacancy
  WHERE ((vac_archived = false) AND (vac_duplicate = false));
 $   DROP VIEW public.cleared_vacancies;
       public          postgres    false    215    215    215    215    215    215    215    215    215    215    215    215    215    215    215    215    215                       0    0    TABLE cleared_vacancies    ACL     �   GRANT SELECT ON TABLE public.cleared_vacancies TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.cleared_vacancies TO utile_agent;
          public          postgres    false    219            �            1259    44008    vacancy_categories    TABLE     �   CREATE TABLE public.vacancy_categories (
    category_id character varying(64) NOT NULL,
    category_name character varying(256)
);
 &   DROP TABLE public.vacancy_categories;
       public         heap    postgres    false                       0    0    TABLE vacancy_categories    ACL     �   GRANT SELECT ON TABLE public.vacancy_categories TO client_agent;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.vacancy_categories TO utile_agent;
          public          postgres    false    220            �            1259    77911    vacancy_classify_error    TABLE     K   CREATE TABLE public.vacancy_classify_error (
    vac_id bigint NOT NULL
);
 *   DROP TABLE public.vacancy_classify_error;
       public         heap    postgres    false            	           0    0    TABLE vacancy_classify_error    ACL     E   GRANT SELECT ON TABLE public.vacancy_classify_error TO client_agent;
          public          postgres    false    222            V           2606    44012 *   vacancy_categories vacancy_categories_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.vacancy_categories
    ADD CONSTRAINT vacancy_categories_pkey PRIMARY KEY (category_id);
 T   ALTER TABLE ONLY public.vacancy_categories DROP CONSTRAINT vacancy_categories_pkey;
       public            postgres    false    220            Z           2606    77926 2   vacancy_classify_error vacancy_classify_error_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.vacancy_classify_error
    ADD CONSTRAINT vacancy_classify_error_pkey PRIMARY KEY (vac_id) INCLUDE (vac_id);
 \   ALTER TABLE ONLY public.vacancy_classify_error DROP CONSTRAINT vacancy_classify_error_pkey;
       public            postgres    false    222            ^           2606    77928 $   vacancy_dataset vacancy_dataset_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public.vacancy_dataset
    ADD CONSTRAINT vacancy_dataset_pkey PRIMARY KEY (vac_id) INCLUDE (vac_id);
 N   ALTER TABLE ONLY public.vacancy_dataset DROP CONSTRAINT vacancy_dataset_pkey;
       public            postgres    false    224            N           2606    34117    vacancy vacancy_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.vacancy
    ADD CONSTRAINT vacancy_pkey PRIMARY KEY (vac_id);
 >   ALTER TABLE ONLY public.vacancy DROP CONSTRAINT vacancy_pkey;
       public            postgres    false    215            X           2606    44017     vacancy_roles vacancy_roles_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.vacancy_roles
    ADD CONSTRAINT vacancy_roles_pkey PRIMARY KEY (role_id);
 J   ALTER TABLE ONLY public.vacancy_roles DROP CONSTRAINT vacancy_roles_pkey;
       public            postgres    false    221            T           2606    36401     vacancy_techs vacancy_techs_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.vacancy_techs
    ADD CONSTRAINT vacancy_techs_pkey PRIMARY KEY (vac_id, tech_name);
 J   ALTER TABLE ONLY public.vacancy_techs DROP CONSTRAINT vacancy_techs_pkey;
       public            postgres    false    216    216            \           2606    77934     vacancy_types vacancy_types_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public.vacancy_types
    ADD CONSTRAINT vacancy_types_pkey PRIMARY KEY (type_name) INCLUDE (type_name);
 J   ALTER TABLE ONLY public.vacancy_types DROP CONSTRAINT vacancy_types_pkey;
       public            postgres    false    223            O           1259    40896    vacancy_vac_employment_idx    INDEX     x   CREATE INDEX vacancy_vac_employment_idx ON public.vacancy USING btree (vac_employment) WITH (deduplicate_items='true');
 .   DROP INDEX public.vacancy_vac_employment_idx;
       public            postgres    false    215            P           1259    40894    vacancy_vac_exp_idx    INDEX     j   CREATE INDEX vacancy_vac_exp_idx ON public.vacancy USING btree (vac_exp) WITH (deduplicate_items='true');
 '   DROP INDEX public.vacancy_vac_exp_idx;
       public            postgres    false    215            Q           1259    34170    vacancy_vac_id_idx    INDEX     h   CREATE INDEX vacancy_vac_id_idx ON public.vacancy USING btree (vac_id) WITH (deduplicate_items='true');
 &   DROP INDEX public.vacancy_vac_id_idx;
       public            postgres    false    215            R           1259    40895    vacancy_vac_schedule_idx    INDEX     t   CREATE INDEX vacancy_vac_schedule_idx ON public.vacancy USING btree (vac_schedule) WITH (deduplicate_items='true');
 ,   DROP INDEX public.vacancy_vac_schedule_idx;
       public            postgres    false    215            a           2606    77935 .   vacancy_dataset vacancy_dataset_type_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.vacancy_dataset
    ADD CONSTRAINT vacancy_dataset_type_name_fkey FOREIGN KEY (type_name) REFERENCES public.vacancy_types(type_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 X   ALTER TABLE ONLY public.vacancy_dataset DROP CONSTRAINT vacancy_dataset_type_name_fkey;
       public          postgres    false    4700    223    224            `           2606    44018 ,   vacancy_roles vacancy_roles_category_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.vacancy_roles
    ADD CONSTRAINT vacancy_roles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.vacancy_categories(category_id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.vacancy_roles DROP CONSTRAINT vacancy_roles_category_id_fkey;
       public          postgres    false    221    220    4694            _           2606    34163 '   vacancy_techs vacancy_techs_vac_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.vacancy_techs
    ADD CONSTRAINT vacancy_techs_vac_id_fkey FOREIGN KEY (vac_id) REFERENCES public.vacancy(vac_id) ON UPDATE CASCADE ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.vacancy_techs DROP CONSTRAINT vacancy_techs_vac_id_fkey;
       public          postgres    false    215    4686    216           