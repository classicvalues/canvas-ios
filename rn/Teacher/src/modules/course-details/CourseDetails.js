/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component, PropTypes } from 'react'
import { connect } from 'react-redux'
import {
  View,
  ScrollView,
  Text,
  Image,
  StyleSheet,
} from 'react-native'

import Images from '../../images'
import i18n from 'format-message'
import CourseDetailsActions from './actions'
import CourseDetailsTab from './components/CourseDetailsTab'
import { stateToProps } from './props'
import Button from 'react-native-button'
import NavigationBackButton from '../../common/components/NavigationBackButton'
import { route } from '../../routing'

type Props = {
  navigator: ReactNavigator,
  course: Course,
  tabs: Tab[],
  courseColors: string[],
  refreshTabs: () => void,
}

export class CourseDetails extends Component<any, Props, any> {
  static navigatorStyle = {
    navBarHidden: true,
  }

  static navigatorButtons = {
    rightButtons: [{
      icon: Images.course.settings,
      title: i18n({
        default: 'Edit',
        description: 'Shown at the top of the course details screen.',
      }),
    }],
  }

  editCourse = () => {
  }

  componentDidMount () {
    this.props.refreshTabs(this.props.course.id)
  }

  selectTab = (tab: Tab) => {
    const courseID = this.props.course.id
    switch (tab.id) {
      case 'assignments':
        const destination = route(`/courses/${courseID}/assignments`)
        this.props.navigator.push(destination)
        break
      default: break
    }
  }

  back = () => {
    this.props.navigator.pop()
  }

  render (): React.Element<View> {
    const course = this.props.course
    const courseColor = this.props.courseColors[course.id]

    const tabs = this.props.tabs.sort((a, b) => a.position - b.position).map((tab) => {
      return <CourseDetailsTab tab={tab} courseColor={courseColor} onPress={this.selectTab} />
    })

    return (
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <View style={styles.headerImageContainer}>
            { course.image_download_url &&
                <Image source={{ uri: course.image_download_url }} style={styles.headerImage} />
            }
            <View style={[styles.headerImageOverlay, { backgroundColor: courseColor }]} />
          </View>
          <View style={styles.navigationBar}>
            <NavigationBackButton onPress={this.back} testID='course-details.navigation-back-btn' />
            <Text style={styles.navigationTitle}>{course.course_code}</Text>
            <Button style={[styles.settingsButton]} onPress={this.editCourse} testID='course-details.navigation-edit-course-btn'>
              <View style={{ paddingLeft: 20 }}>
                <Image source={Images.course.settings} onPress={this.back} style={styles.navButtonImage} />
              </View>
            </Button>
          </View>

          <View style={styles.headerBottomContainer} >
            <Text style={styles.headerTitle}>{course.name}</Text>
            <Text style={styles.headerSubtitle}>Spring 2017</Text>
          </View>
        </View>
        <View style={styles.tabContainer}>
          {tabs}
        </View>
      </ScrollView>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
    paddingTop: 20,
    height: 235,
  },
  headerTitle: {
    backgroundColor: 'transparent',
    color: 'white',
    fontWeight: 'bold',
    fontSize: 20,
    textAlign: 'center',
    marginBottom: 2,
  },
  headerSubtitle: {
    color: 'white',
    opacity: 0.75,
    backgroundColor: 'transparent',
  },
  headerImageContainer: {
    position: 'absolute',
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerImage: {
    position: 'absolute',
    height: 235,
    width: 400,
  },
  headerImageOverlay: {
    position: 'absolute',
    opacity: 0.75,
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerBottomContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 44,
  },
  navigationBar: {
    position: 'absolute',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingLeft: 10,
    paddingRight: 10,
    height: 44,
    top: 20,
    left: 0,
    right: 0,
  },
  navigationTitle: {
    color: 'white',
    backgroundColor: 'transparent',
    fontWeight: 'bold',
    fontSize: 18,
  },
  settingsButton: {
    width: 24,
  },
  navButtonImage: {
    resizeMode: 'contain',
    tintColor: 'white',
  },
  tabContainer: {
    flex: 1,
    justifyContent: 'flex-start',
  },
})

const tabListShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  hidden: PropTypes.bool,
  visibility: PropTypes.string.isRequired,
  position: PropTypes.number.isRequired,
})

CourseDetails.propTypes = {
  tabs: PropTypes.arrayOf(tabListShape).isRequired,
  courseColors: PropTypes.objectOf(React.PropTypes.string).isRequired,
}

let Connected = connect(stateToProps, CourseDetailsActions)(CourseDetails)
export default (Connected: Component<any, Props, any>)
