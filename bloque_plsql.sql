
DECLARE
    -- VARRAY para almacenar los impactos estimados
    TYPE listaImpacto IS VARRAY(100) OF VARCHAR2(100);
    va_impacto listaImpacto := listaImpacto();
    
    -- RECORD para capturar cada fila del cursor
    TYPE datos_contaminacion_rec IS RECORD(
        nombreComuna COMUNA.nombre_comuna%TYPE,
        fechaRegion CONTAMINACION.fecha_registro%TYPE,
        descripcionFuente fuentes_contaminacion.descripcion%TYPE,
        impactoEstimado fuentes_contaminacion.impacto_estimado%TYPE,
        instrumentoMedicion mediciones.instrumento_medicion%TYPE,
        fechaHora VARCHAR2(10),
        descripcionRestriccion restricciones.descripcion%TYPE,
        fechaInicio restricciones.fecha_inicio%TYPE,
        fecha_fin restricciones.fecha_fin%TYPE
    );
    
    v_datos datos_contaminacion_rec;
    v_index NUMBER := 0;
    
    -- Cursor explícito con JOIN de varias tablas
    CURSOR C_datos_contaminacion IS
        SELECT DISTINCT 
            c.nombre_comuna,
            cont.fecha_registro,
            fc.descripcion,
            fc.impacto_estimado,
            me.instrumento_medicion,
            TO_CHAR(me.fecha_hora,'HH24:MI') as hora_medicion,
            rest.descripcion as descripcion_restriccion,
            rest.fecha_inicio,
            rest.fecha_fin
        FROM comuna c 
        JOIN poseer po ON po.id_comuna = c.id_comuna
        JOIN contaminacion cont ON po.id_contaminacion = cont.id_contaminacion
        JOIN fuentes_contaminacion fc ON fc.id_contaminacion = cont.id_contaminacion
        JOIN mediciones me ON me.id_contaminacion = cont.id_contaminacion
        JOIN restricciones rest ON rest.id_comuna = c.id_comuna;
BEGIN
    -- Inicializar VARRAY
    va_impacto := listaImpacto();

    DBMS_OUTPUT.PUT_LINE('=== DATOS DEL CURSOR ===');

    OPEN C_datos_contaminacion;
    LOOP
        FETCH C_datos_contaminacion INTO 
            v_datos.nombreComuna,
            v_datos.fechaRegion,
            v_datos.descripcionFuente,
            v_datos.impactoEstimado,
            v_datos.instrumentoMedicion,
            v_datos.fechaHora,
            v_datos.descripcionRestriccion,
            v_datos.fechaInicio,
            v_datos.fecha_fin;
            
        EXIT WHEN C_datos_contaminacion%NOTFOUND;
        
        v_index := v_index + 1;
        
        -- Extender y almacenar impacto estimado solo si no excede el límite del VARRAY
        IF v_index <= va_impacto.LIMIT THEN
            va_impacto.EXTEND;
            va_impacto(v_index) := v_datos.impactoEstimado;
        END IF;
        
        -- Mostrar cada registro
        DBMS_OUTPUT.PUT_LINE('Registro ' || v_index || ':');
        DBMS_OUTPUT.PUT_LINE('  Comuna: ' || v_datos.nombreComuna);
        DBMS_OUTPUT.PUT_LINE('  Fecha Registro: ' || TO_CHAR(v_datos.fechaRegion, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('  Descripcion Fuente: ' || NVL(v_datos.descripcionFuente, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  Impacto Estimado: ' || NVL(TO_CHAR(v_datos.impactoEstimado), 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  Instrumento: ' || NVL(v_datos.instrumentoMedicion, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  Hora Medicion: ' || NVL(v_datos.fechaHora, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  Restriccion: ' || NVL(v_datos.descripcionRestriccion, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  Fecha Inicio: ' || TO_CHAR(v_datos.fechaInicio, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('  Fecha Fin: ' || TO_CHAR(v_datos.fecha_fin, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('  ----------------------------------------');
    END LOOP;
    CLOSE C_datos_contaminacion;

    -- Mostrar contenido del VARRAY
    IF v_index > 0 THEN
        DBMS_OUTPUT.PUT_LINE('=== CONTENIDO DEL VARRAY (Impactos Estimados) ===');
        FOR i IN 1..LEAST(v_index, va_impacto.LIMIT) LOOP
            IF va_impacto(i) IS NOT NULL THEN
                
                DBMS_OUTPUT.PUT_LINE('Indice ' || i || ': ' || count(va_impacto(i)));
            END IF;
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se procesaron registros en el VARRAY');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF C_datos_contaminacion%ISOPEN THEN
            CLOSE C_datos_contaminacion;
            END IF;
END;
/


