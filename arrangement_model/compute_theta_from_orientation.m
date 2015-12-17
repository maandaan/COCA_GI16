function theta = compute_theta_from_orientation(orient)

if orient(1) == 0 && orient(2) > 0
    theta = pi/2;
    return
end

if orient(1) == 0 && orient(2) < 0
    theta = -pi/2;
    return
end

theta = atan(orient(2) / orient(1));
if orient(1) < 0
    theta = theta + pi;
end

end
