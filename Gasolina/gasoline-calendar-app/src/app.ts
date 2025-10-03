import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Calendar from './components/Calendar';

const App = () => {
    return (
        <Router>
            <Switch>
                <Route path="/" exact component={Calendar} />
            </Switch>
        </Router>
    );
};

ReactDOM.render(<App />, document.getElementById('root'));