create or replace PROCEDURE P_GUARDAR_VIDEO (
    P_codigo_VIDEO OUT TBL_VIDEOS.codigo_VIDEO%TYPE,
    P_codigo_usuario TBL_VIDEOS.codigo_usuario%TYPE,
    P_codigo_estado_video TBL_VIDEOS.codigo_estado_video%TYPE,
    P_codigo_idioma TBL_VIDEOS.codigo_idioma%TYPE,
    P_codigo_canal TBL_VIDEOS.codigo_canal%TYPE,
    P_nombre_video TBL_VIDEOS.nombre_video%TYPE,
    P_resolucion TBL_VIDEOS.resolucion%TYPE,
    P_duracion_segundos TBL_VIDEOS.duracion_segundos%TYPE,
    P_cantidad_likes TBL_VIDEOS.cantidad_likes%TYPE,
    P_cantidad_dislikes TBL_VIDEOS.cantidad_dislikes%TYPE,
    P_cantidad_visualizaciones TBL_VIDEOS.cantidad_visualizaciones%TYPE,
    P_fecha_subida TBL_VIDEOS.fecha_subida%TYPE,
    P_descripcion TBL_VIDEOS.descripcion%TYPE,
    P_cantidad_shares TBL_VIDEOS.cantidad_shares%TYPE,
    P_url TBL_VIDEOS.url%TYPE
) AS
    V_CANTIDAD_USUARIOS NUMBER;
    V_CANTIDAD_CANALES NUMBER;
    E_USUARIO_NO_EXISTE EXCEPTION;
    E_CANAL_NO_EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(1)
    INTO V_CANTIDAD_USUARIOS
    FROM TBL_USUARIOS
    WHERE CODIGO_USUARIO = P_CODIGO_USUARIO;

    SELECT COUNT(1)
    INTO V_CANTIDAD_CANALES
    FROM TBL_CANALES
    WHERE CODIGO_CANAL = P_CODIGO_CANAL;

    IF (V_CANTIDAD_USUARIOS <= 0) THEN
        RAISE E_USUARIO_NO_EXISTE;
    END IF;

    IF (V_CANTIDAD_CANALES <= 0) THEN
        RAISE E_CANAL_NO_EXISTE;
    END IF;
    P_codigo_VIDEO := SEQ_CODIGO_VIDEO.NEXTVAL;
    INSERT INTO tbl_videos (
        codigo_video,
        codigo_usuario,
        codigo_estado_video,
        codigo_idioma,
        codigo_canal,
        nombre_video,
        resolucion,
        duracion_segundos,
        cantidad_likes,
        cantidad_dislikes,
        cantidad_visualizaciones,
        fecha_subida,
        descripcion,
        cantidad_shares,
        url
    ) VALUES (
        P_codigo_VIDEO,
        P_codigo_usuario,
        P_codigo_estado_video,
        P_codigo_idioma,
        P_codigo_canal,
        P_nombre_video,
        P_resolucion,
        P_duracion_segundos,
        P_cantidad_likes,
        P_cantidad_dislikes,
        P_cantidad_visualizaciones,
        P_fecha_subida,
        P_descripcion,
        P_cantidad_shares,
        P_url
    ); 

    FOR V_USUARIO IN 
    (
        SELECT * 
        FROM TBL_USUARIOS_X_CANAL
        WHERE CODIGO_CANAL = P_CODIGO_CANAL
    ) LOOP 
        --ENVIAR LA NOTIFICACION
        P_GUARDAR_NOTIFICACION(
            P_CODIGO_USUARIO_DESTINO => V_USUARIO.CODIGO_USUARIO,
            P_TEXTO_NOTIFICACION => 'SE HA SUBIDO UN NUEVO VIDEO AL CANAL ' || P_CODIGO_CANAL ,
            P_CODIGO_VIDEO => P_codigo_VIDEO,
            P_CODIGO_USUARIO_ORIGEN => P_codigo_usuario
        );
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN E_USUARIO_NO_EXISTE THEN
        DBMS_OUTPUT.PUT_LINE('USUARIO NO EXISTE');
    WHEN E_CANAL_NO_EXISTE THEN
        DBMS_OUTPUT.PUT_LINE('CANAL NO EXISTE');
END;

DECLARE
    V_CODIGO_VIDEO NUMBER;
BEGIN
    P_GUARDAR_VIDEO (
        P_codigo_VIDEO => V_CODIGO_VIDEO,
        P_codigo_usuario => 1,
        P_codigo_estado_video => 1,
        P_codigo_idioma => 1,
        P_codigo_canal => 3, --TIENE 6 USUARIOS
        P_nombre_video => 'APRENDIENDO PROCEDIMIENTOS ALMACENADOS',
        P_resolucion => '1080',
        P_duracion_segundos => 12312,
        P_cantidad_likes => 0,
        P_cantidad_dislikes => 0,
        P_cantidad_visualizaciones => 0,
        P_fecha_subida => SYSDATE,
        P_descripcion => 'APRENDER PROCEDIMIENTOS',
        P_cantidad_shares => 0,
        P_url => 'https://youtube.com/v/2342352'
    );
    DBMS_OUTPUT.PUT_LINE('CODIGO VIDEO GUARDADO:  ' || V_CODIGO_VIDEO );
END;
