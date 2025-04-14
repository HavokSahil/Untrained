use actix_web::{ web, Error, HttpResponse, Responder, Result};
use sqlx::MySqlPool;
use crate::models::user::{ CreateUser, LoginUser, UpdateUser, UserResponse};

// POST /create_user
pub async fn create_user(
    pool: web::Data<MySqlPool>,
    payload: web::Json<CreateUser>
) -> Result<impl Responder, Error> {
    let res = sqlx::query!(
        r#"
        INSERT INTO users(email, name, password, role)
        VALUES(?, ?, ?, ?);
        "#,
        payload.email,
        payload.name,
        payload.password,
        payload.role
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(res) => {
            Ok(HttpResponse::Created().json({
                serde_json::json!({
                    "message": "User created successfully",
                    "name": payload.name,
                    "email": payload.email,
                    "role": payload.role,
                    "rows_affected": res.rows_affected(),
                })
            }))
        },
        Err(e)=> {
            eprintln!(" Error inserting user: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to create user",
                    "details": e.to_string(),
                })
            }))
        }
    }
}

// GET /users
pub async fn get_users(
    pool: web::Data<MySqlPool>
) -> Result<impl Responder, Error> {

    let result: Result<Vec<UserResponse>, sqlx::Error> = sqlx::query_as!(
        UserResponse,
        "SELECT email, name, role
        FROM users"
    )
        .fetch_all(pool.get_ref())
        .await;

    match result {
        Ok(users) => Ok(HttpResponse::Ok().json(users)),
        Err(e) => {
            eprintln!("Error fetching users: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch users",
                    "details": e.to_string(),
                })
            }))
        }
    }
}

// GET /users/{id}
pub async fn get_user_by_email(
    pool: web::Data<MySqlPool>,
    path: web::Path<String>,
) -> Result<impl Responder, Error> {
    let email = path.into_inner();

    let result = sqlx::query_as!(
        UserResponse,
        "SELECT email, name, role
        FROM users
        WHERE email = ?",
        &email
    )
    .fetch_optional(pool.get_ref())
    .await;

    match result {
        Ok(Some(user)) => Ok(HttpResponse::Ok().json(user)),
        Ok(None) => Ok(HttpResponse::NotFound().finish()),
        Err(e) => {
            eprintln!("Error fetching user: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch user",
                    "details": e.to_string(),
                })
            }))
        }
    }
}

// GET /users?email={email}&pass={password}
pub async fn get_user_by_email_and_password(
    pool: web::Data<MySqlPool>,
    payload: web::Json<LoginUser>,
) -> Result<impl Responder, Error> {

    let email = &payload.email;
    let password = &payload.password;


    let result = sqlx::query_as!(
        UserResponse,
        r#"
        SELECT email, name, role
        FROM users
        WHERE email = ? AND password = ?
        "#,
        email,
        password
    )
    .fetch_optional(pool.get_ref())
    .await;

    match result {
        Ok(Some(user)) => Ok(HttpResponse::Ok().json({
            serde_json::json!({
                "message": "User found",
                "name": user.name,
                "email": user.email,
                "role": user.role,
            })
        })),
        Ok(None) => Ok(HttpResponse::Unauthorized().json({
            serde_json::json!({ "error": "Invalid email or password" })
        })),
        Err(e) => {
            eprintln!("Database error: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Something went wrong",
                    "details": e.to_string()
                })
            }))
        }
    }
}

// PUT /users/{id}
pub async fn update_user(
    pool: web::Data<MySqlPool>,
    path: web::Path<String>,
    payload: web::Json<UpdateUser>
) -> Result<impl Responder, Error> {

    let email = path.into_inner();

    let result = sqlx::query!(
        "UPDATE users SET
        name = ?,
        role = ?
        WHERE email = ?",
        payload.name,
        payload.role,
        email
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(result) => {
            Ok(HttpResponse::Ok().json({
                serde_json::json!({
                    "message": "User updated successfully",
                    "name": payload.name,
                    "role": payload.role,
                    "rows_affected": result.rows_affected(),
                })
            }))
        },
        Err(e) => {
            eprintln!("Error updating user: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to update user",
                    "details": e.to_string(),
                })
            }))
        }
    }
}

// DELETE /users/{id}
pub async fn delete_user(
    pool: web::Data<MySqlPool>,
    path: web::Path<String>,
) -> Result<impl Responder, Error> {

    let email = path.into_inner();

    let result = sqlx::query!(
        "DELETE FROM users WHERE email = ?",
        &email
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(res) => {
            if res.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json({
                    serde_json::json!({
                        "message": "User deleted successfully",
                        "rows_affected": res.rows_affected(),
                    })
                }))
            } else {
                Ok(HttpResponse::NotFound().finish())
            }
        },
        Err(e) => {
            eprintln!("Error deleting user: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to delete user",
                    "details": e.to_string(),
                })
            }))
        }
    }
}