CREATE OR REPLACE PROCEDURE P_ACTUALIZAR_SUSCRIPTORES (
    P_CODIGO_USUARIO TBL_USUARIOS.CODIGO_USUARIO%TYPE,
    P_CODIGO_CANAL TBL_CANALES.CODIGO_CANAL%TYPE
) AS
    V_CANTIDAD_USUARIOS NUMBER;
    V_CANTIDAD_CANALES NUMBER;
    V_CODIGO_USUARIO_DUENIO NUMBER;
    V_CANTIDAD_SUSCRIPTORES NUMBER;
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
    
    INSERT INTO tbl_usuarios_x_canal (
        codigo_usuario,
        codigo_canal,
        fecha_suscripcion
    ) VALUES (
        P_CODIGO_USUARIO,
        P_CODIGO_CANAL,
        SYSDATE
    );
    
    -- OTRA POSIBLE SOLUCION PERO NO EFICIENTE
    --SELECT COUNT(1)
    --INTO V_CANTIDAD_USUARIOS_CANAL
    --FROM TBL_USUARIOS_X_CANAL
    --WHERE CODIGO_CANAL = P_CODIGO_CANAL;
    
    --ACTUALIZAR LA CANTIDAD DE SUSCRIPTORES A 1
    UPDATE TBL_CANALES
    SET CANTIDAD_SUSCRIPTORES = CANTIDAD_SUSCRIPTORES + 1
    WHERE CODIGO_CANAL = P_CODIGO_CANAL;
    
    SELECT CANTIDAD_SUSCRIPTORES, CODIGO_USUARIO 
    INTO V_CANTIDAD_SUSCRIPTORES, V_CODIGO_USUARIO_DUENIO
    FROM TBL_CANALES
    WHERE CODIGO_CANAL = P_CODIGO_CANAL;
    
    IF (V_CANTIDAD_SUSCRIPTORES = 10) THEN
        --ENVIAR NOTIFICACION
        P_GUARDAR_NOTIFICACION(
            P_CODIGO_USUARIO_DESTINO => V_CODIGO_USUARIO_DUENIO,
            P_TEXTO_NOTIFICACION => 'FELICIDADES!, LLEGASTE A LOS 10 SUSCRIPTORES!!!' ,
            P_CODIGO_VIDEO => NULL,
            P_CODIGO_USUARIO_ORIGEN => P_CODIGO_USUARIO
        );
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN E_USUARIO_NO_EXISTE THEN
        DBMS_OUTPUT.PUT_LINE('USUARIO NO EXISTE');
    WHEN E_CANAL_NO_EXISTE THEN
        DBMS_OUTPUT.PUT_LINE('CANAL NO EXISTE');
    WHEN OTHERS THEN
        ROLLBACK;
END;

SET SERVEROUTPUT ON;

BEGIN
    P_ACTUALIZAR_SUSCRIPTORES(6,3);
END;

SELECT * FROM TBL_USUARIOS;
SELECT * FROM TBL_CANALES; -- 34534565  + 1
SELECT * FROM TBL_USUARIOS_X_CANAL;

CREATE SEQUENCE SQ_CODIGO_NOTIFICACION;

CREATE OR REPLACE PROCEDURE P_GUARDAR_NOTIFICACION(
    P_CODIGO_USUARIO_DESTINO TBL_NOTIFICACIONES.CODIGO_USUARIO_DESTINO%TYPE,
    P_TEXTO_NOTIFICACION TBL_NOTIFICACIONES.TEXTO_NOTIFICACION%TYPE,
    P_CODIGO_VIDEO TBL_NOTIFICACIONES.CODIGO_VIDEO%TYPE,
    P_CODIGO_USUARIO_ORIGEN TBL_NOTIFICACIONES.CODIGO_USUARIO_ORIGEN%TYPE
) AS
BEGIN
  INSERT INTO tbl_notificaciones (
        codigo_notificacion,
        codigo_usuario_destino,
        fecha_hora_envio,
        texto_notificacion,
        codigo_video,
        codigo_usuario_origen
    ) VALUES (
        SQ_CODIGO_NOTIFICACION.NEXTVAL,
        P_CODIGO_USUARIO_DESTINO,
        SYSDATE,
        P_TEXTO_NOTIFICACION,
        P_CODIGO_VIDEO,
        P_CODIGO_USUARIO_ORIGEN
    ); 
    COMMIT;
END;

BEGIN
    P_GUARDAR_NOTIFICACION(
        P_CODIGO_USUARIO_DESTINO => 9,
        P_TEXTO_NOTIFICACION => 'HOLA ESTA ES UNA NOTIFICACION DE PRUEBA' ,
        P_CODIGO_VIDEO => 1,
        P_CODIGO_USUARIO_ORIGEN => 5
    );
END;

SELECT * FROM TBL_NOTIFICACIONES;
SELECT * FROM TBL_CANALES;