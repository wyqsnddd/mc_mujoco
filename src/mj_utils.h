#ifndef MJ_UTILS_H
#define MJ_UTILS_H

#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <vector>

namespace mc_mujoco
{

/*! Load XML model and initialize */
bool mujoco_init(const char * modelfile);

/*! Create GLFW window */
void mujoco_create_window();

/*! Sets initial qpos and qvel in mjData */
bool mujoco_set_const(const std::vector<double> & qpos, const std::vector<double> & qvel);

/*! Returns timestep defined in XML. */
double mujoco_get_timestep();

/*! Get true position of robot root joint. */
void mujoco_get_root_pos(Eigen::Vector3d & pos);

/*! Get true orientation of robot root joint. */
void mujoco_get_root_orient(Eigen::Quaterniond & quat);

/*! Get true linear velocity of robot root joint. */
void mujoco_get_root_lin_vel(Eigen::Vector3d & linvel);

/*! Get true angular velocity of robot root joint. */
void mujoco_get_root_ang_vel(Eigen::Vector3d & angvel);

/*! Get true linear acceleration of robot root joint. */
void mujoco_get_root_lin_acc(Eigen::Vector3d & linacc);

/*! Get true angular acceleration of robot root joint. */
void mujoco_get_root_ang_acc(Eigen::Vector3d & angacc);

/*! Get positions of all joints except the freejoint. */
void mujoco_get_joint_pos(std::vector<double> & qpos);

/*! Get velocities of all joints except the freejoint. */
void mujoco_get_joint_vel(std::vector<double> & qvel);

/*! Get joint torques (in joint space).
 * See definition of qfrc_actuator at mujoco.org.
 */
void mujoco_get_joint_qfrc(std::vector<double> & qfrc);

/*! Generic function to read sensor meansurements.
 * Returns false if sensor name is not present in model.
 */
bool mujoco_get_sensordata(std::vector<double> & read, const std::string & sensor_name);

/*! Get names and ids of all joints except the freejoint. */
void mujoco_get_joints(std::vector<std::string> & names, std::vector<int> & ids);

/*! Get names and ids of all actuated joints (NOT the names of actuators). */
void mujoco_get_motors(std::vector<std::string> & names, std::vector<int> & ids);

/*! Sets the control data after scaling down by gear ratio.
 * Returns false if there is a vector size mismatch.
 */
bool mujoco_set_ctrl(const std::vector<double> & ctrl);

/*! Increment simulation state by one step. */
void mujoco_step();

/*! Render.
 * Returns false if window is closed.
 */
bool mujoco_render();

/*! Cleanup. */
void mujoco_cleanup();

} // namespace mc_mujoco

#endif // MJ_UTILS_H_
