CREATE SEQUENCE SEQ_CODIGO_COMENTARIO;

CREATE OR REPLACE PROCEDURE P_GUARDAR_COMENTARIO (
    P_CODIGO_COMENTARIO OUT TBL_COMENTARIOS.CODIGO_COMENTARIO%TYPE,
    P_CODIGO_COMENTARIO_PADRE TBL_COMENTARIOS.CODIGO_COMENTARIO_PADRE%TYPE,
    P_CODIGO_USUARIO TBL_COMENTARIOS.CODIGO_USUARIO%TYPE,
    P_CODIGO_VIDEO TBL_COMENTARIOS.CODIGO_VIDEO%TYPE,
    P_COMENTARIO TBL_COMENTARIOS.COMENTARIO%TYPE
) AS
    V_CODIGO_USUARIO_DUENIO NUMBER;
BEGIN
    P_CODIGO_COMENTARIO := SEQ_CODIGO_COMENTARIO.NEXTVAL;
    INSERT INTO tbl_comentarios (
        codigo_comentario,
        codigo_comentario_padre,
        codigo_usuario,
        codigo_video,
        comentario,
        fecha_publicacion,
        cantidad_likes
    ) VALUES (
        P_CODIGO_COMENTARIO,
        P_CODIGO_COMENTARIO_PADRE,
        P_CODIGO_USUARIO,
        P_CODIGO_VIDEO,
        P_COMENTARIO,
        SYSDATE,
        0
    );
    
    SELECT CODIGO_USUARIO 
    INTO V_CODIGO_USUARIO_DUENIO
    FROM TBL_VIDEOS
    WHERE CODIGO_VIDEO = P_CODIGO_VIDEO;
    
    P_GUARDAR_NOTIFICACION(
        P_CODIGO_USUARIO_DESTINO => V_CODIGO_USUARIO_DUENIO,
        P_TEXTO_NOTIFICACION => 'HOLA, ALGUIEN HIZO UN COMENTARIO EN TU VIDEO CON CODIGO: ' || P_CODIGO_VIDEO ,
        P_CODIGO_VIDEO => P_CODIGO_VIDEO,
        P_CODIGO_USUARIO_ORIGEN => P_CODIGO_USUARIO
    );
    
    COMMIT;
END;


DECLARE
    V_CODIGO_COMENTARIO NUMBER;
BEGIN
    P_GUARDAR_COMENTARIO (
        P_CODIGO_COMENTARIO => V_CODIGO_COMENTARIO,
        P_CODIGO_COMENTARIO_PADRE => NULL,
        P_CODIGO_USUARIO => 1,
        P_CODIGO_VIDEO => 1,
        P_COMENTARIO => 'QUE VIDEO MAS HORRIBLE'
    );
    DBMS_OUTPUT.PUT_LINE('cOMENTARIO GUARDADO: ' || V_CODIGO_COMENTARIO );
END;