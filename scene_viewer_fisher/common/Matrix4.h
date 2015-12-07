//
// Matrix4.h
//

#include "Vec3f.h"

class Matrix4
{
public:
    
    //
    // Math properties
    //
    Matrix4 Transpose() const;
    
    //
    // Vector transforms
    //
    Vec3f TransformPoint(const Vec3f &point) const
    {
        float w = point.x * _entries[0][3] + point.y * _entries[1][3] + point.z * _entries[2][3] + _entries[3][3];
        if(w)
        {
            const float invW = 1.0f / w;
            return Vec3f( (point.x * _entries[0][0] + point.y * _entries[1][0] + point.z * _entries[2][0] + _entries[3][0]) * invW,
                          (point.x * _entries[0][1] + point.y * _entries[1][1] + point.z * _entries[2][1] + _entries[3][1]) * invW,
                          (point.x * _entries[0][2] + point.y * _entries[1][2] + point.z * _entries[2][2] + _entries[3][2]) * invW);
        }
        else
        {
            return Vec3f(0.0f, 0.0f, 0.0f);
        }
    }

    Vec3f TransformPointNoProjection(const Vec3f &point) const
    {
        return Vec3f( (point.x * _entries[0][0] + point.y * _entries[1][0] + point.z * _entries[2][0] + _entries[3][0]),
                      (point.x * _entries[0][1] + point.y * _entries[1][1] + point.z * _entries[2][1] + _entries[3][1]),
                      (point.x * _entries[0][2] + point.y * _entries[1][2] + point.z * _entries[2][2] + _entries[3][2]));
    }
    
    Vec3f TransformNormal(const Vec3f &normal) const
    {
        return Vec3f(normal.x * _entries[0][0] + normal.y * _entries[1][0] + normal.z * _entries[2][0],
                     normal.x * _entries[0][1] + normal.y * _entries[1][1] + normal.z * _entries[2][1],
                     normal.x * _entries[0][2] + normal.y * _entries[1][2] + normal.z * _entries[2][2]);
    }

    //
    // Accessors
    //
    float* operator [] (int Row)
    {
        return _entries[Row];
    }
    const float* operator [] (int Row) const
    {
        return _entries[Row];
    }
    
    //
    // Transformation matrices
    //
    static Matrix4 Identity();
    static Matrix4 Scaling(const Vec3f &scaleFactors);
    static Matrix4 Scaling(float scaleFactor)
    {
        return Scaling(Vec3f(scaleFactor, scaleFactor, scaleFactor));
    }
    static Matrix4 Translation(const Vec3f &pos);
    static Matrix4 Rotation(const Vec3f &axis, float angle, const Vec3f &center);
    static Matrix4 Rotation(const Vec3f &axis, float angle);
    static Matrix4 RotationX(float theta);
    static Matrix4 RotationY(float theta);
    static Matrix4 RotationZ(float theta);
    static Matrix4 Camera(const Vec3f &eye, const Vec3f &look, const Vec3f &up, const Vec3f &right);
    static Matrix4 PerspectiveFov(float FOV, float aspect, float zNear, float zFar);
    static Matrix4 BoundingBoxToUnitSphere(const Vec3f &boundingBoxMin, const Vec3f &boundingBoxMax);

private:
    float _entries[4][4];
};

Matrix4 operator * (const Matrix4 &left, const Matrix4 &right);
